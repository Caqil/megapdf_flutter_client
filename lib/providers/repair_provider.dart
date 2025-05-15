// lib/providers/repair_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/models/repair_result.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';

class RepairState {
  final bool isLoading;
  final RepairResult? result;
  final String? errorMessage;

  RepairState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  RepairState copyWith({
    bool? isLoading,
    RepairResult? result,
    String? errorMessage,
  }) {
    return RepairState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class RepairNotifier extends StateNotifier<RepairState> {
  final ApiClient _apiClient;

  RepairNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(RepairState());

  Future<RepairResult> repairPdf({
    required PdfFile file,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Make sure we have the actual file
      if (file.file == null) {
        throw AppError(
          message: 'File not found',
          type: AppErrorType.fileMissing,
        );
      }

      // Upload file and get repair result
      final response = await _apiClient.uploadFile(
        ApiConstants.pdfRepair,
        file.file!,
      );

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to repair PDF',
          type: AppErrorType.server,
        );
      }

      // Parse response data
      final data = response.data;
      if (data == null) {
        throw AppError(
          message: 'Invalid response from server',
          type: AppErrorType.server,
        );
      }

      final result = RepairResult.fromJson(data);

      // Update state
      state = state.copyWith(
        isLoading: false,
        result: result,
      );

      return result;
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      final error = AppError(
        message: 'Failed to repair PDF: ${e.toString()}',
        type: AppErrorType.unknown,
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      );

      throw error;
    }
  }

  // Reset state
  void reset() {
    state = RepairState();
  }
}

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for repair state
final repairProvider =
    StateNotifierProvider<RepairNotifier, RepairState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RepairNotifier(apiClient: apiClient);
});

// Loading state provider
final repairLoadingProvider = Provider<bool>((ref) {
  return ref.watch(repairProvider).isLoading;
});

// Result provider
final repairResultProvider = Provider<RepairResult?>((ref) {
  return ref.watch(repairProvider).result;
});

// Error message provider
final repairErrorProvider = Provider<String?>((ref) {
  return ref.watch(repairProvider).errorMessage;
});

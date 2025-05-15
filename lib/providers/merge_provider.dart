// lib/providers/merge_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/models/merge_result.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';

class MergeState {
  final bool isLoading;
  final MergeResult? result;
  final String? errorMessage;

  MergeState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  MergeState copyWith({
    bool? isLoading,
    MergeResult? result,
    String? errorMessage,
  }) {
    return MergeState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class MergeNotifier extends StateNotifier<MergeState> {
  final ApiClient _apiClient;

  MergeNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(MergeState());

  Future<MergeResult> mergePdfs({
    required List<PdfFile> files,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Validate files
      if (files.isEmpty || files.length < 2) {
        throw AppError(
          message: 'Please select at least 2 PDF files to merge',
          type: AppErrorType.validation,
        );
      }

      // Check if all files have the required file attribute
      for (final file in files) {
        if (file.file == null) {
          throw AppError(
            message: 'File ${file.name} not found',
            type: AppErrorType.fileMissing,
          );
        }
      }

      // Extract the File objects
      final fileObjects = files.map((f) => f.file!).toList();

      // Upload files and get merge result
      final response = await _apiClient.uploadFiles(
        ApiConstants.pdfMerge,
        fileObjects,
      );

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to merge PDFs',
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

      final result = MergeResult.fromJson(data);

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
        message: 'Failed to merge PDFs: ${e.toString()}',
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
    state = MergeState();
  }
}

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for merge state
final mergeProvider = StateNotifierProvider<MergeNotifier, MergeState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MergeNotifier(apiClient: apiClient);
});

// Loading state provider
final mergeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(mergeProvider).isLoading;
});

// Result provider
final mergeResultProvider = Provider<MergeResult?>((ref) {
  return ref.watch(mergeProvider).result;
});

// Error message provider
final mergeErrorProvider = Provider<String?>((ref) {
  return ref.watch(mergeProvider).errorMessage;
});

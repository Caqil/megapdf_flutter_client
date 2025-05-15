// lib/providers/convert_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/models/conversion_result.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';

class ConvertState {
  final bool isLoading;
  final ConversionResult? result;
  final String? errorMessage;

  ConvertState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  ConvertState copyWith({
    bool? isLoading,
    ConversionResult? result,
    String? errorMessage,
  }) {
    return ConvertState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class ConvertNotifier extends StateNotifier<ConvertState> {
  final ApiClient _apiClient;

  ConvertNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(ConvertState());

  Future<ConversionResult> convertFile({
    required PdfFile file,
    required String outputFormat,
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

      // Create form data for the API request
      final formData = {
        'outputFormat': outputFormat.toLowerCase(),
      };

      // Upload file and get conversion result
      final response = await _apiClient.uploadFile(
        ApiConstants.pdfConvert,
        file.file!,
        formData: formData,
      );

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to convert file',
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

      final result = ConversionResult.fromJson(data);

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
        message: 'Failed to convert file: ${e.toString()}',
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
    state = ConvertState();
  }
}

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for convert state
final convertProvider =
    StateNotifierProvider<ConvertNotifier, ConvertState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ConvertNotifier(apiClient: apiClient);
});

// Loading state provider
final convertLoadingProvider = Provider<bool>((ref) {
  return ref.watch(convertProvider).isLoading;
});

// Result provider
final convertResultProvider = Provider<ConversionResult?>((ref) {
  return ref.watch(convertProvider).result;
});

// Error message provider
final convertErrorProvider = Provider<String?>((ref) {
  return ref.watch(convertProvider).errorMessage;
});
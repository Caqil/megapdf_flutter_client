// lib/providers/compress_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/models/compression_result.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';

class CompressState {
  final bool isLoading;
  final CompressionResult? result;
  final String? errorMessage;

  CompressState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  CompressState copyWith({
    bool? isLoading,
    CompressionResult? result,
    String? errorMessage,
  }) {
    return CompressState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class CompressNotifier extends StateNotifier<CompressState> {
  final ApiClient _apiClient;

  CompressNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(CompressState());

  Future<CompressionResult> compressPdf({
    required PdfFile file,
    required int quality,
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
        'quality': quality.toString(),
      };

      // Upload file and get compression result
      final response = await _apiClient.uploadFile(
        ApiConstants.pdfCompress,
        file.file!,
        formData: formData,
      );

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to compress PDF',
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

      final result = CompressionResult.fromJson(data);

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
        message: 'Failed to compress PDF: ${e.toString()}',
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
    state = CompressState();
  }
}

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for compress state
final compressProvider =
    StateNotifierProvider<CompressNotifier, CompressState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CompressNotifier(apiClient: apiClient);
});

// Loading state provider
final compressLoadingProvider = Provider<bool>((ref) {
  return ref.watch(compressProvider).isLoading;
});

// Result provider
final compressResultProvider = Provider<CompressionResult?>((ref) {
  return ref.watch(compressProvider).result;
});

// Error message provider
final compressErrorProvider = Provider<String?>((ref) {
  return ref.watch(compressProvider).errorMessage;
});

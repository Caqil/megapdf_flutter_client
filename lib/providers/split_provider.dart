// lib/providers/split_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/models/split_result.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';

class SplitState {
  final bool isLoading;
  final SplitResult? result;
  final SplitJobStatus? jobStatus;
  final String? errorMessage;

  SplitState({
    this.isLoading = false,
    this.result,
    this.jobStatus,
    this.errorMessage,
  });

  SplitState copyWith({
    bool? isLoading,
    SplitResult? result,
    SplitJobStatus? jobStatus,
    String? errorMessage,
  }) {
    return SplitState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      jobStatus: jobStatus ?? this.jobStatus,
      errorMessage: errorMessage,
    );
  }
}

class SplitNotifier extends StateNotifier<SplitState> {
  final ApiClient _apiClient;

  SplitNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(SplitState());

  // Get page count of a PDF file
  Future<int> getPageCount(PdfFile file) async {
    try {
      // Make sure we have the actual file
      if (file.file == null) {
        throw AppError(
          message: 'File not found',
          type: AppErrorType.fileMissing,
        );
      }

      // Upload file to get PDF info
      final response = await _apiClient.uploadFile(
        ApiConstants.pdfInfo,
        file.file!,
      );

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to get PDF info',
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

      final pageCount = data['pageCount'] as int? ?? 0;
      return pageCount;
    } on AppError {
      rethrow;
    } catch (e) {
      throw AppError(
        message: 'Failed to get page count: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Split PDF file
  Future<SplitResult> splitPdf({
    required PdfFile file,
    required List<int> pages,
    bool extractAsIndividualFiles = false,
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

      // Make sure we have pages to extract
      if (pages.isEmpty) {
        throw AppError(
          message: 'No pages specified for extraction',
          type: AppErrorType.validation,
        );
      }

      // Create form data for the API request
      final formData = {
        'pages': pages.join(','),
        'extractAsIndividualFiles': extractAsIndividualFiles.toString(),
      };

      // Upload file and get split result
      final response = await _apiClient.uploadFile(
        ApiConstants.pdfSplit,
        file.file!,
        formData: formData,
      );

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to split PDF',
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

      final result = SplitResult.fromJson(data);

      // If the job is large, it might be processed asynchronously
      if (result.isLargeJob &&
          result.jobId != null &&
          result.statusUrl != null) {
        // Start polling for job status
        await _pollJobStatus(result.jobId!, result.statusUrl!);
      }

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
        message: 'Failed to split PDF: ${e.toString()}',
        type: AppErrorType.unknown,
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      );

      throw error;
    }
  }

  // Poll job status for large split operations
  Future<void> _pollJobStatus(String jobId, String statusUrl) async {
    const maxAttempts = 30; // Maximum polling attempts
    const delaySeconds = 2; // Delay between polls in seconds

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await _apiClient.get(statusUrl);

        if (response.statusCode != 200) {
          continue; // Skip to next attempt
        }

        final data = response.data;
        if (data == null) {
          continue; // Skip to next attempt
        }

        final status = SplitJobStatus.fromJson(data);

        // Update state with current status
        state = state.copyWith(jobStatus: status);

        // If job is completed or failed, stop polling
        if (status.isCompleted || status.isError) {
          if (status.isError) {
            throw AppError(
              message: status.error ?? 'Split operation failed',
              type: AppErrorType.server,
            );
          }

          // Update split result with completed job data
          if (state.result != null) {
            final updatedResult = SplitResult(
              success: true,
              message: 'Split operation completed',
              jobId: jobId,
              statusUrl: statusUrl,
              originalName: state.result!.originalName,
              totalPages: state.result!.totalPages,
              estimatedSplits: status.results.length,
              isLargeJob: true,
              splitParts: status.results,
            );

            state = state.copyWith(result: updatedResult);
          }

          return;
        }

        // Wait before next poll
        await Future.delayed(Duration(seconds: delaySeconds));
      } catch (e) {
        if (e is AppError) {
          rethrow;
        }

        // Wait before next attempt
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    // If we reach here, polling timed out
    throw AppError(
      message: 'Split operation timed out. Please check back later.',
      type: AppErrorType.server,
    );
  }

  // Check job status (can be called explicitly by UI)
  Future<SplitJobStatus> checkJobStatus(String statusUrl) async {
    try {
      final response = await _apiClient.get(statusUrl);

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to get job status',
          type: AppErrorType.server,
        );
      }

      final data = response.data;
      if (data == null) {
        throw AppError(
          message: 'Invalid response from server',
          type: AppErrorType.server,
        );
      }

      final status = SplitJobStatus.fromJson(data);

      // Update state with current status
      state = state.copyWith(jobStatus: status);

      return status;
    } on AppError {
      rethrow;
    } catch (e) {
      throw AppError(
        message: 'Failed to check job status: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Reset state
  void reset() {
    state = SplitState();
  }
}

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for split state
final splitProvider = StateNotifierProvider<SplitNotifier, SplitState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SplitNotifier(apiClient: apiClient);
});

// Loading state provider
final splitLoadingProvider = Provider<bool>((ref) {
  return ref.watch(splitProvider).isLoading;
});

// Result provider
final splitResultProvider = Provider<SplitResult?>((ref) {
  return ref.watch(splitProvider).result;
});

// Job status provider
final splitJobStatusProvider = Provider<SplitJobStatus?>((ref) {
  return ref.watch(splitProvider).jobStatus;
});

// Error message provider
final splitErrorProvider = Provider<String?>((ref) {
  return ref.watch(splitProvider).errorMessage;
});

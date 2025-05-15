// lib/providers/protect_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';

// Define a class to hold the protection result
class ProtectionResult {
  final bool success;
  final String message;
  final String fileUrl;
  final String filename;
  final String originalName;

  ProtectionResult({
    required this.success,
    required this.message,
    required this.fileUrl,
    required this.filename,
    required this.originalName,
  });

  factory ProtectionResult.fromJson(Map<String, dynamic> json) {
    return ProtectionResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      originalName: json['originalName'] as String? ?? '',
    );
  }
}

class ProtectState {
  final bool isLoading;
  final ProtectionResult? result;
  final String? errorMessage;

  ProtectState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  ProtectState copyWith({
    bool? isLoading,
    ProtectionResult? result,
    String? errorMessage,
  }) {
    return ProtectState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class ProtectNotifier extends StateNotifier<ProtectState> {
  final ApiClient _apiClient;

  ProtectNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(ProtectState());

  Future<ProtectionResult> protectPdf({
    required PdfFile file,
    required String password,
    bool restrictPrinting = true,
    bool restrictEditing = true,
    bool restrictCopying = true,
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

      // Validate password
      if (password.isEmpty) {
        throw AppError(
          message: 'Password cannot be empty',
          type: AppErrorType.validation,
        );
      }

      // Create form data for the API request
      final formData = {
        'password': password,
        'restrictPrinting': restrictPrinting.toString(),
        'restrictEditing': restrictEditing.toString(),
        'restrictCopying': restrictCopying.toString(),
      };

      // Upload file and get protection result
      final response = await _apiClient.uploadFile(
        ApiConstants.pdfProtect,
        file.file!,
        formData: formData,
      );

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to protect PDF',
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

      final result = ProtectionResult.fromJson(data);

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
        message: 'Failed to protect PDF: ${e.toString()}',
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
    state = ProtectState();
  }
}

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for protect state
final protectProvider =
    StateNotifierProvider<ProtectNotifier, ProtectState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProtectNotifier(apiClient: apiClient);
});

// Loading state provider
final protectLoadingProvider = Provider<bool>((ref) {
  return ref.watch(protectProvider).isLoading;
});

// Result provider
final protectResultProvider = Provider<ProtectionResult?>((ref) {
  return ref.watch(protectProvider).result;
});

// Error message provider
final protectErrorProvider = Provider<String?>((ref) {
  return ref.watch(protectProvider).errorMessage;
});

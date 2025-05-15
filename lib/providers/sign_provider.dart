// lib/providers/sign_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';
import 'package:megapdf_flutter_client/data/models/sign_result.dart';

// TextElement class for signing documents with text
class TextElement {
  final String id;
  final int page;
  final Offset position;
  final String text;
  final Color textColor;
  final double fontSize;
  final String fontFamily;
  final double rotation;

  TextElement({
    required this.id,
    required this.page,
    required this.position,
    required this.text,
    required this.textColor,
    required this.fontSize,
    required this.fontFamily,
    required this.rotation,
  });
}

// SignatureElement class for signing documents with drawn signatures
class SignatureElement {
  final String id;
  final int page;
  final Offset position;
  final Size size;
  final String data; // Base64 encoded image data
  final double rotation;
  final double scale;

  SignatureElement({
    required this.id,
    required this.page,
    required this.position,
    required this.size,
    required this.data,
    required this.rotation,
    required this.scale,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page': page,
      'position': {'x': position.dx, 'y': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'data': data,
      'rotation': rotation,
      'scale': scale,
    };
  }
}

class SignState {
  final bool isLoading;
  final SignResult? result;
  final String? errorMessage;

  SignState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  SignState copyWith({
    bool? isLoading,
    SignResult? result,
    String? errorMessage,
  }) {
    return SignState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class SignNotifier extends StateNotifier<SignState> {
  final ApiClient _apiClient;

  SignNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(SignState());

  Future<SignResult> signPdf({
    required PdfFile file,
    required List<SignatureElement> signatures,
    required List<TextElement> textElements,
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

      // Validate signatures and text elements
      if (signatures.isEmpty && textElements.isEmpty) {
        throw AppError(
          message: 'Please add at least one signature or text element',
          type: AppErrorType.validation,
        );
      }

      // Create form data for the API request
      final formData = {
        'signatures': signatures.map((s) => s.toJson()).toList(),
        'textElements': textElements
            .map((t) => {
                  'id': t.id,
                  'page': t.page,
                  'position': {'x': t.position.dx, 'y': t.position.dy},
                  'text': t.text,
                  'textColor': t.textColor.value.toRadixString(16),
                  'fontSize': t.fontSize,
                  'fontFamily': t.fontFamily,
                  'rotation': t.rotation,
                })
            .toList(),
      };

      // Upload file and get sign result
      final response = await _apiClient.uploadFile(
        ApiConstants.pdfSign,
        file.file!,
        formData: formData,
      );

      if (response.statusCode != 200) {
        throw AppError(
          message: 'Failed to sign PDF',
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

      final result = SignResult.fromJson(data);

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
        message: 'Failed to sign PDF: ${e.toString()}',
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
    state = SignState();
  }
}

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for sign state
final signProvider = StateNotifierProvider<SignNotifier, SignState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SignNotifier(apiClient: apiClient);
});

// Loading state provider
final signLoadingProvider = Provider<bool>((ref) {
  return ref.watch(signProvider).isLoading;
});

// Result provider
final signResultProvider = Provider<SignResult?>((ref) {
  return ref.watch(signProvider).result;
});

// Error message provider
final signErrorProvider = Provider<String?>((ref) {
  return ref.watch(signProvider).errorMessage;
});

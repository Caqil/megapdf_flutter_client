// lib/core/error/error_handler.dart

import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';

class ErrorHandler {
  // Handle error and show appropriate message
  static String getErrorMessage(dynamic error) {
    if (error is AppError) {
      return error.message;
    } else if (error is Error) {
      // Handle Dart errors
      return error.toString();
    } else {
      // Handle other errors
      return error?.toString() ?? AppConstants.errorGenericMessage;
    }
  }

  // Get error title
  static String getErrorTitle(dynamic error) {
    if (error is AppError) {
      return error.title;
    } else {
      return AppConstants.errorGenericTitle;
    }
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) async {
    final errorTitle = title ?? getErrorTitle(error);
    final errorMessage = message ?? getErrorMessage(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(errorTitle),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onRetry,
  }) {
    final errorMessage = message ?? getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  // Check if error is a network error
  static bool isNetworkError(dynamic error) {
    if (error is AppError) {
      return error.isNetworkError;
    }
    return false;
  }

  // Check if error is an authentication error
  static bool isAuthError(dynamic error) {
    if (error is AppError) {
      return error.isAuthError;
    }
    return false;
  }

  // Check if error is a payment-related error
  static bool isPaymentError(dynamic error) {
    if (error is AppError) {
      return error.isPaymentError;
    }
    return false;
  }

  // Handle error based on type
  static void handleError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    VoidCallback? onAuthError,
    VoidCallback? onPaymentError,
  }) {
    if (isAuthError(error) && onAuthError != null) {
      // Handle authentication errors
      onAuthError();
    } else if (isPaymentError(error) && onPaymentError != null) {
      // Handle payment errors
      onPaymentError();
    } else {
      // Show error dialog for other errors
      showErrorDialog(
        context,
        error,
        onRetry: onRetry,
      );
    }
  }
}

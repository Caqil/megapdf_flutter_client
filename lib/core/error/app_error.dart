// lib/core/error/app_error.dart

import 'package:equatable/equatable.dart';

// Define error types
enum AppErrorType {
  // Network errors
  network,

  // Server errors
  server,

  // Client errors
  badRequest,
  unauthorized,
  forbidden,
  notFound,

  // Other errors
  cancel,
  unknown,
  validation,
  fileSystem,

  // Business logic errors
  fileSize,
  fileType,
  fileAccess,
  fileMissing,

  // Authentication errors
  invalidCredentials,
  accountLocked,

  // Payment errors
  paymentRequired,
  insufficient,
}

class AppError extends Equatable implements Exception {
  final String message;
  final int? code;
  final AppErrorType type;
  final dynamic data;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.code,
    this.type = AppErrorType.unknown,
    this.data,
    this.stackTrace,
  });

  // Get error title based on error type
  String get title {
    switch (type) {
      case AppErrorType.network:
        return 'Network Error';
      case AppErrorType.server:
        return 'Server Error';
      case AppErrorType.badRequest:
        return 'Invalid Request';
      case AppErrorType.unauthorized:
        return 'Authentication Error';
      case AppErrorType.forbidden:
        return 'Access Denied';
      case AppErrorType.notFound:
        return 'Not Found';
      case AppErrorType.fileSize:
        return 'File Too Large';
      case AppErrorType.fileType:
        return 'Invalid File Type';
      case AppErrorType.fileAccess:
        return 'File Access Error';
      case AppErrorType.fileMissing:
        return 'File Not Found';
      case AppErrorType.validation:
        return 'Validation Error';
      case AppErrorType.paymentRequired:
        return 'Payment Required';
      case AppErrorType.insufficient:
        return 'Insufficient Balance';
      case AppErrorType.invalidCredentials:
        return 'Invalid Credentials';
      case AppErrorType.accountLocked:
        return 'Account Locked';
      case AppErrorType.cancel:
        return 'Operation Cancelled';
      case AppErrorType.unknown:
      default:
        return 'Error';
    }
  }

  // Checks if error is a network error
  bool get isNetworkError => type == AppErrorType.network;

  // Checks if error is a server error
  bool get isServerError => type == AppErrorType.server;

  // Checks if error is an authentication error
  bool get isAuthError =>
      type == AppErrorType.unauthorized ||
      type == AppErrorType.invalidCredentials ||
      type == AppErrorType.accountLocked;

  // Checks if error is a payment-related error
  bool get isPaymentError =>
      type == AppErrorType.paymentRequired || type == AppErrorType.insufficient;

  // Checks if error is a file-related error
  bool get isFileError =>
      type == AppErrorType.fileSize ||
      type == AppErrorType.fileType ||
      type == AppErrorType.fileAccess ||
      type == AppErrorType.fileMissing;

  @override
  List<Object?> get props => [message, code, type, data];

  @override
  String toString() =>
      'AppError(message: $message, code: $code, type: $type, data: $data)';
}

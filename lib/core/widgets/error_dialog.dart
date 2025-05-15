// lib/core/widgets/error_dialog.dart

import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';

import '../error/app_error.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final IconData icon;
  final Color iconColor;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onClose,
    this.showCloseButton = true,
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.error,
  });

  // Helper constructor for app error
  factory ErrorDialog.fromError(
    AppError error, {
    VoidCallback? onRetry,
    VoidCallback? onClose,
    bool showCloseButton = true,
  }) {
    IconData errorIcon;
    Color errorColor;

    switch (error.type) {
      case AppErrorType.network:
        errorIcon = Icons.signal_wifi_off;
        errorColor = AppColors.warning;
        break;
      case AppErrorType.unauthorized:
      case AppErrorType.forbidden:
        errorIcon = Icons.lock_outline;
        errorColor = AppColors.warning;
        break;
      case AppErrorType.fileSize:
      case AppErrorType.fileType:
      case AppErrorType.fileAccess:
      case AppErrorType.fileMissing:
        errorIcon = Icons.insert_drive_file_outlined;
        errorColor = AppColors.warning;
        break;
      case AppErrorType.paymentRequired:
      case AppErrorType.insufficient:
        errorIcon = Icons.account_balance_wallet_outlined;
        errorColor = AppColors.warning;
        break;
      default:
        errorIcon = Icons.error_outline;
        errorColor = AppColors.error;
    }

    return ErrorDialog(
      title: error.title,
      message: error.message,
      onRetry: onRetry,
      onClose: onClose,
      showCloseButton: showCloseButton,
      icon: errorIcon,
      iconColor: errorColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actions: [
        if (showCloseButton)
          AppButton(
            label: 'Close',
            onPressed: onClose ?? () => Navigator.of(context).pop(),
            type: AppButtonType.text,
          ),
        if (onRetry != null)
          AppButton(
            label: 'Retry',
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            type: AppButtonType.primary,
          ),
      ],
      actionsAlignment: MainAxisAlignment.center,
      buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  // Show error dialog with context
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onClose,
    bool showCloseButton = true,
    IconData icon = Icons.error_outline,
    Color iconColor = AppColors.error,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        onClose: onClose,
        showCloseButton: showCloseButton,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  // Show error dialog from app error
  static Future<void> showError(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    VoidCallback? onClose,
    bool showCloseButton = true,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog.fromError(
        error,
        onRetry: onRetry,
        onClose: onClose,
        showCloseButton: showCloseButton,
      ),
    );
  }
}

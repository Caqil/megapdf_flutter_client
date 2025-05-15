import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/core/error/error_handler.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:megapdf_flutter_client/core/utils/permissions_helper.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePickerButton extends StatelessWidget {
  final Function(PdfFile) onFilePicked;
  final List<String> allowedExtensions;
  final int maxFileSize;
  final String? dialogTitle;
  final String buttonText;
  final IconData? icon;
  final AppButtonType buttonType;
  final AppButtonSize buttonSize;
  final bool fullWidth;
  final double? width;
  final bool checkPermissions;

  const FilePickerButton({
    super.key,
    required this.onFilePicked,
    this.allowedExtensions = const ['pdf'],
    this.maxFileSize = AppConstants.maxFileSize,
    this.dialogTitle,
    this.buttonText = 'Choose File',
    this.icon = Icons.upload_file,
    this.buttonType = AppButtonType.primary,
    this.buttonSize = AppButtonSize.medium,
    this.fullWidth = false,
    this.width,
    this.checkPermissions = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: buttonText,
      icon: icon,
      type: buttonType,
      size: buttonSize,
      fullWidth: fullWidth,
      width: width,
      onPressed: () => _pickFile(context),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      if (checkPermissions) {
        final hasPermission =
            await PermissionsHelper.requestStoragePermission();
        if (!hasPermission) {
          // Check if permission is permanently denied
          final isPermanentlyDenied =
              await PermissionsHelper.isPermanentlyDenied(Permission.storage) ||
                  await PermissionsHelper.isPermanentlyDenied(
                      Permission.photos);
          if (isPermanentlyDenied) {
            // Show dialog to guide user to app settings
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                    'Storage permission is required to pick files. Please enable it in app settings.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await PermissionsHelper.openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
            return; // Exit without throwing an error
          }
          throw AppError(
            message: 'Storage permission is required to pick files',
            type: AppErrorType.fileAccess,
          );
        }
      }

      final file = await FileUtils.pickFile(
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );

      if (file == null) {
        // User cancelled
        return;
      }

      // Check file size
      if (!FileUtils.isFileSizeWithinLimits(file.size, maxFileSize)) {
        throw AppError(
          message:
              'File size is too large. Maximum allowed size is ${FileUtils.getFormattedFileSize(maxFileSize)}',
          type: AppErrorType.fileSize,
        );
      }

      // Check file extension
      if (!allowedExtensions.contains(file.extension?.toLowerCase())) {
        throw AppError(
          message:
              'Invalid file type. Allowed formats: ${allowedExtensions.join(', ')}',
          type: AppErrorType.fileType,
        );
      }

      onFilePicked(file);
    } catch (error) {
      ErrorHandler.showErrorSnackBar(
        context,
        error,
      );
    }
  }
}

class PdfPickerButton extends StatelessWidget {
  final Function(PdfFile) onFilePicked;
  final int maxFileSize;
  final String buttonText;
  final IconData? icon;
  final AppButtonType buttonType;
  final AppButtonSize buttonSize;
  final bool fullWidth;
  final double? width;

  const PdfPickerButton({
    super.key,
    required this.onFilePicked,
    this.maxFileSize = AppConstants.maxFileSize,
    this.buttonText = 'Select PDF',
    this.icon = Icons.picture_as_pdf,
    this.buttonType = AppButtonType.primary,
    this.buttonSize = AppButtonSize.medium,
    this.fullWidth = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return FilePickerButton(
      onFilePicked: onFilePicked,
      allowedExtensions: AppConstants.pdfExtensions,
      maxFileSize: maxFileSize,
      dialogTitle: 'Select PDF File',
      buttonText: buttonText,
      icon: icon,
      buttonType: buttonType,
      buttonSize: buttonSize,
      fullWidth: fullWidth,
      width: width,
    );
  }
}

class MultipleFilePickerButton extends StatelessWidget {
  final Function(List<PdfFile>) onFilesPicked;
  final List<String> allowedExtensions;
  final int maxFileSize;
  final int maxFiles;
  final String? dialogTitle;
  final String buttonText;
  final IconData? icon;
  final AppButtonType buttonType;
  final AppButtonSize buttonSize;
  final bool fullWidth;
  final double? width;
  final bool checkPermissions;

  const MultipleFilePickerButton({
    super.key,
    required this.onFilesPicked,
    this.allowedExtensions = const ['pdf'],
    this.maxFileSize = AppConstants.maxFileSize,
    this.maxFiles = 10,
    this.dialogTitle,
    this.buttonText = 'Choose Files',
    this.icon = Icons.upload_file,
    this.buttonType = AppButtonType.primary,
    this.buttonSize = AppButtonSize.medium,
    this.fullWidth = false,
    this.width,
    this.checkPermissions = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: buttonText,
      icon: icon,
      type: buttonType,
      size: buttonSize,
      fullWidth: fullWidth,
      width: width,
      onPressed: () => _pickFiles(context),
    );
  }

  Future<void> _pickFiles(BuildContext context) async {
    try {
      if (checkPermissions) {
        final hasPermission =
            await PermissionsHelper.requestStoragePermission();
        if (!hasPermission) {
          // Check if permission is permanently denied
          final isPermanentlyDenied =
              await PermissionsHelper.isPermanentlyDenied(Permission.storage) ||
                  await PermissionsHelper.isPermanentlyDenied(
                      Permission.photos);
          if (isPermanentlyDenied) {
            // Show dialog to guide user to app settings
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                    'Storage permission is required to pick files. Please enable it in app settings.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await PermissionsHelper.openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
            return; // Exit without throwing an error
          }
          throw AppError(
            message: 'Storage permission is required to pick files',
            type: AppErrorType.fileAccess,
          );
        }
      }

      final files = await FileUtils.pickMultiplePdfFiles(maxFiles: maxFiles);

      if (files.isEmpty) {
        // User cancelled or no files selected
        return;
      }

      // Check file sizes and extensions
      for (final file in files) {
        if (!FileUtils.isFileSizeWithinLimits(file.size, maxFileSize)) {
          throw AppError(
            message:
                'File ${file.name} is too large. Maximum allowed size is ${FileUtils.getFormattedFileSize(maxFileSize)}',
            type: AppErrorType.fileSize,
          );
        }

        if (!allowedExtensions.contains(file.extension?.toLowerCase())) {
          throw AppError(
            message:
                'Invalid file type for ${file.name}. Allowed formats: ${allowedExtensions.join(', ')}',
            type: AppErrorType.fileType,
          );
        }
      }

      onFilesPicked(files);
    } catch (error) {
      ErrorHandler.showErrorSnackBar(
        context,
        error,
      );
    }
  }
}

class MultiplePdfPickerButton extends StatelessWidget {
  final Function(List<PdfFile>) onFilesPicked;
  final int maxFileSize;
  final int maxFiles;
  final String buttonText;
  final IconData? icon;
  final AppButtonType buttonType;
  final AppButtonSize buttonSize;
  final bool fullWidth;
  final double? width;

  const MultiplePdfPickerButton({
    super.key,
    required this.onFilesPicked,
    this.maxFileSize = AppConstants.maxFileSize,
    this.maxFiles = AppConstants.maxFilesForMerge,
    this.buttonText = 'Select PDFs',
    this.icon = Icons.picture_as_pdf,
    this.buttonType = AppButtonType.primary,
    this.buttonSize = AppButtonSize.medium,
    this.fullWidth = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return MultipleFilePickerButton(
      onFilesPicked: onFilesPicked,
      allowedExtensions: AppConstants.pdfExtensions,
      maxFileSize: maxFileSize,
      maxFiles: maxFiles,
      dialogTitle: 'Select PDF Files',
      buttonText: buttonText,
      icon: icon,
      buttonType: buttonType,
      buttonSize: buttonSize,
      fullWidth: fullWidth,
      width: width,
    );
  }
}

class DragDropFileUpload extends StatelessWidget {
  final Function(PdfFile) onFilePicked;
  final List<String> allowedExtensions;
  final int maxFileSize;
  final String prompt;
  final IconData icon;
  final String? dropHint;
  final double height;
  final double? width;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? borderColor;

  const DragDropFileUpload({
    super.key,
    required this.onFilePicked,
    this.allowedExtensions = const ['pdf'],
    this.maxFileSize = AppConstants.maxFileSize,
    this.prompt = 'Drag and drop a file here',
    this.icon = Icons.cloud_upload,
    this.dropHint = 'or click to select a file',
    this.height = 200,
    this.width,
    this.fullWidth = false,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: () => _pickFile(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              prompt,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (dropHint != null) ...[
              const SizedBox(height: 8),
              Text(
                dropHint!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final hasPermission = await PermissionsHelper.requestStoragePermission();
      if (!hasPermission) {
        // Check if permission is permanently denied
        final isPermanentlyDenied =
            await PermissionsHelper.isPermanentlyDenied(Permission.storage) ||
                await PermissionsHelper.isPermanentlyDenied(Permission.photos);
        if (isPermanentlyDenied) {
          // Show dialog to guide user to app settings
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'Storage permission is required to pick files. Please enable it in app settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await PermissionsHelper.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
          return; // Exit without throwing an error
        }
        throw AppError(
          message: 'Storage permission is required to pick files',
          type: AppErrorType.fileAccess,
        );
      }

      final file = await FileUtils.pickFile(
        allowedExtensions: allowedExtensions,
      );

      if (file == null) {
        // User cancelled
        return;
      }

      // Check file size
      if (!FileUtils.isFileSizeWithinLimits(file.size, maxFileSize)) {
        throw AppError(
          message:
              'File size is too large. Maximum allowed size is ${FileUtils.getFormattedFileSize(maxFileSize)}',
          type: AppErrorType.fileSize,
        );
      }

      // Check file extension
      if (!allowedExtensions.contains(file.extension?.toLowerCase())) {
        throw AppError(
          message:
              'Invalid file type. Allowed formats: ${allowedExtensions.join(', ')}',
          type: AppErrorType.fileType,
        );
      }

      onFilePicked(file);
    } catch (error) {
      ErrorHandler.showErrorSnackBar(
        context,
        error,
      );
    }
  }
}

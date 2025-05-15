// lib/presentation/screens/result/result_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/error/error_handler.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';
import 'package:megapdf_flutter_client/core/widgets/app_loading.dart';
import 'package:megapdf_flutter_client/presentation/router/route_names.dart';
import 'package:megapdf_flutter_client/presentation/widgets/result/download_card.dart';
import 'package:path_provider/path_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String operation;
  final String fileUrl;
  final String fileName;
  final Map<String, dynamic>? additionalData;

  const ResultScreen({
    super.key,
    required this.operation,
    required this.fileUrl,
    required this.fileName,
    this.additionalData,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isDownloading = false;
  String? _downloadedFilePath;

  // Get operation title based on operation type
  String _getOperationTitle() {
    switch (widget.operation) {
      case AppConstants.operationCompress:
        return 'PDF Compressed';
      case AppConstants.operationConvert:
        return 'PDF Converted';
      case AppConstants.operationMerge:
        return 'PDFs Merged';
      case AppConstants.operationSplit:
        return 'PDF Split';
      case AppConstants.operationProtect:
        return 'PDF Protected';
      case AppConstants.operationUnlock:
        return 'PDF Unlocked';
      case AppConstants.operationRepair:
        return 'PDF Repaired';
      case AppConstants.operationRotate:
        return 'PDF Rotated';
      case AppConstants.operationWatermark:
        return 'Watermark Added';
      case AppConstants.operationRemove:
        return 'Pages Removed';
      case AppConstants.operationPageNumbers:
        return 'Page Numbers Added';
      case AppConstants.operationSign:
        return 'PDF Signed';
      case AppConstants.operationOcr:
        return 'OCR Completed';
      default:
        return 'Operation Completed';
    }
  }

  // Get success message based on operation type
  String _getSuccessMessage() {
    switch (widget.operation) {
      case AppConstants.operationCompress:
        return AppConstants.successCompressMessage;
      case AppConstants.operationConvert:
        return AppConstants.successConvertMessage;
      case AppConstants.operationMerge:
        return AppConstants.successMergeMessage;
      case AppConstants.operationSplit:
        return AppConstants.successSplitMessage;
      case AppConstants.operationProtect:
        return AppConstants.successProtectMessage;
      case AppConstants.operationUnlock:
        return AppConstants.successUnlockMessage;
      case AppConstants.operationRepair:
        return AppConstants.successRepairMessage;
      case AppConstants.operationRotate:
        return 'PDF rotated successfully.';
      case AppConstants.operationWatermark:
        return AppConstants.successWatermarkMessage;
      case AppConstants.operationRemove:
        return AppConstants.successRemoveMessage;
      case AppConstants.operationPageNumbers:
        return AppConstants.successPageNumbersMessage;
      case AppConstants.operationSign:
        return AppConstants.successSignMessage;
      case AppConstants.operationOcr:
        return AppConstants.successOcrMessage;
      default:
        return AppConstants.successOperationTitle;
    }
  }

  // Get operation icon
  IconData _getOperationIcon() {
    switch (widget.operation) {
      case AppConstants.operationCompress:
        return Icons.compress;
      case AppConstants.operationConvert:
        return Icons.transform;
      case AppConstants.operationMerge:
        return Icons.merge_type;
      case AppConstants.operationSplit:
        return Icons.call_split;
      case AppConstants.operationProtect:
        return Icons.lock_outline;
      case AppConstants.operationUnlock:
        return Icons.lock_open;
      case AppConstants.operationRepair:
        return Icons.build;
      case AppConstants.operationRotate:
        return Icons.rotate_right;
      case AppConstants.operationWatermark:
        return Icons.branding_watermark;
      case AppConstants.operationRemove:
        return Icons.delete_outline;
      case AppConstants.operationPageNumbers:
        return Icons.format_list_numbered;
      case AppConstants.operationSign:
        return Icons.draw;
      case AppConstants.operationOcr:
        return Icons.document_scanner;
      default:
        return Icons.check_circle_outline;
    }
  }

  Future<void> _downloadFile() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // Create a temporary directory for downloaded files if it doesn't exist
      final tempDir = await getTemporaryDirectory();
      final downloadDir = Directory('${tempDir.path}/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Log the file URL for debugging
      debugPrint('Downloading file from URL: ${widget.fileUrl}');

      // Download file to temporary location
      final tempFile = await FileUtils.saveFileFromUrl(
        widget.fileUrl,
        widget.fileName,
        directoryPath: downloadDir.path,
      );

      if (!mounted) return;

      // Store the temporary file path for preview
      setState(() {
        _downloadedFilePath = tempFile.path;
      });

      // Save to downloads
      final savedPath = await FileUtils.saveFileToDownloads(
        tempFile,
        widget.fileName,
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      if (savedPath != null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved successfully: ${widget.fileName}'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => _openFile(savedPath),
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      // Show error message with details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: ${error.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _downloadFile,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      await FileUtils.openFile(filePath);
    } catch (error) {
      if (!mounted) return;

      ErrorHandler.showErrorSnackBar(
        context,
        error,
      );
    }
  }

  Future<void> _previewFile() async {
    // If we've already downloaded the file, use that path for preview
    if (_downloadedFilePath != null &&
        File(_downloadedFilePath!).existsSync()) {
      _navigateToPreview();
      return;
    }

    try {
      setState(() {
        _isDownloading = true;
      });

      // Create a temporary directory for downloaded files if it doesn't exist
      final tempDir = await getTemporaryDirectory();
      final previewDir = Directory('${tempDir.path}/previews');
      if (!await previewDir.exists()) {
        await previewDir.create(recursive: true);
      }

      // Download file for preview
      final tempFile = await FileUtils.saveFileFromUrl(
        widget.fileUrl,
        widget.fileName,
        directoryPath: previewDir.path,
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _downloadedFilePath = tempFile.path;
      });

      // Navigate to preview screen
      _navigateToPreview();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      ErrorHandler.showErrorSnackBar(
        context,
        error,
      );
    }
  }

  void _navigateToPreview() {
    // Use the URL or the local file path
    if (_downloadedFilePath != null &&
        File(_downloadedFilePath!).existsSync()) {
      // We already have a local file, use it
      context.push(
        RouteNames.fileViewerPath,
        extra: {
          'fileUrl': widget.fileUrl,
          'fileName': widget.fileName,
          'localFilePath': _downloadedFilePath,
        },
      );
    } else {
      // Use the URL
      context.push(
        RouteNames.fileViewerPath,
        extra: {
          'fileUrl': widget.fileUrl,
          'fileName': widget.fileName,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getOperationTitle()),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go(RouteNames.homePath),
          ),
        ],
      ),
      body: _isDownloading
          ? Center(
              child: AppLoading(
                message: 'Downloading file...',
                size: LoadingSize.large,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Success icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getOperationIcon(),
                      color: AppColors.success,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Success title and message
                  Text(
                    _getOperationTitle(),
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSuccessMessage(),
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Download card
                  DownloadCard(
                    fileName: widget.fileName,
                    fileUrl: widget.fileUrl,
                    isDownloading: _isDownloading,
                    onDownload: _downloadFile,
                    onPreview: _previewFile,
                  ),
                  const SizedBox(height: 24),

                  // Operation details
                  if (widget.operation == AppConstants.operationCompress &&
                      widget.additionalData != null) ...[
                    _CompressionDetails(data: widget.additionalData!),
                  ] else if (widget.operation == AppConstants.operationMerge &&
                      widget.additionalData != null) ...[
                    _MergeDetails(data: widget.additionalData!),
                  ] else if (widget.operation == AppConstants.operationSplit &&
                      widget.additionalData != null) ...[
                    _SplitDetails(data: widget.additionalData!),
                  ],
                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        label: 'New Operation',
                        icon: Icons.add,
                        onPressed: () => context.go(RouteNames.homePath),
                        type: AppButtonType.outline,
                      ),
                      const SizedBox(width: 16),
                      AppButton(
                        label: 'Done',
                        icon: Icons.check,
                        onPressed: () => context.go(RouteNames.homePath),
                        type: AppButtonType.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _CompressionDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CompressionDetails({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final originalSize = data['originalSize'] as int? ?? 0;
    final compressedSize = data['compressedSize'] as int? ?? 0;
    final compressionRatio = data['compressionRatio'] as String? ?? '0%';

    // Calculate size reduction
    final reduction = originalSize - compressedSize;
    final reductionPercentage =
        originalSize > 0 ? (reduction / originalSize * 100) : 0;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Compression Details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(
                  label: 'Original',
                  value: FileUtils.getFormattedFileSize(originalSize),
                  icon: Icons.insert_drive_file,
                  color: AppColors.info,
                ),
                _DetailItem(
                  label: 'Compressed',
                  value: FileUtils.getFormattedFileSize(compressedSize),
                  icon: Icons.compress,
                  color: AppColors.success,
                ),
                _DetailItem(
                  label: 'Saved',
                  value: '${reductionPercentage.toStringAsFixed(1)}%',
                  icon: Icons.save_alt,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: reductionPercentage / 100,
              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
              color: AppColors.success,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'You saved ${FileUtils.getFormattedFileSize(reduction)} (${reductionPercentage.toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MergeDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const _MergeDetails({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mergedSize = data['mergedSize'] as int? ?? 0;
    final totalInputSize = data['totalInputSize'] as int? ?? 0;
    final fileCount = data['fileCount'] as int? ?? 0;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Merge Details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(
                  label: 'Files Merged',
                  value: fileCount.toString(),
                  icon: Icons.file_copy,
                  color: AppColors.info,
                ),
                _DetailItem(
                  label: 'Input Size',
                  value: FileUtils.getFormattedFileSize(totalInputSize),
                  icon: Icons.input,
                  color: AppColors.primary,
                ),
                _DetailItem(
                  label: 'Output Size',
                  value: FileUtils.getFormattedFileSize(mergedSize),
                  icon: Icons.output,
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SplitDetails({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPages = data['totalPages'] as int? ?? 0;
    final splitParts = data['splitParts'];
    final splitCount = splitParts is List ? splitParts.length : 0;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Split Details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(
                  label: 'Total Pages',
                  value: totalPages.toString(),
                  icon: Icons.description,
                  color: AppColors.info,
                ),
                _DetailItem(
                  label: 'Files Created',
                  value: splitCount.toString(),
                  icon: Icons.call_split,
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

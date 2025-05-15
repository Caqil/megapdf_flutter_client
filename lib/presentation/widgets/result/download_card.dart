import 'dart:io';
import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/core/error/error_handler.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';
import 'package:path/path.dart' as path;

class DownloadCard extends StatefulWidget {
  final String fileName;
  final String fileUrl;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback? onPreview;
  final String? description;

  const DownloadCard({
    super.key,
    required this.fileName,
    required this.fileUrl,
    this.isDownloading = false,
    required this.onDownload,
    this.onPreview,
    this.description,
  });

  @override
  State<DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<DownloadCard> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _tempFilePath;
  bool _fileDownloaded = false;

  @override
  void initState() {
    super.initState();
    _isDownloading = widget.isDownloading;
  }

  @override
  void didUpdateWidget(DownloadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDownloading != widget.isDownloading) {
      setState(() {
        _isDownloading = widget.isDownloading;
      });
    }
  }

  Future<void> _downloadFile() async {
    if (_isDownloading) return;

    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      // Download file with progress tracking
      final file = await FileUtils.saveFileFromUrl(
        widget.fileUrl,
        widget.fileName,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      // Store the temporary file path
      _tempFilePath = file.path;

      // Save to downloads directory
      final savedPath = await FileUtils.saveFileToDownloads(
        file,
        widget.fileName,
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _fileDownloaded = savedPath != null;
        });

        // Show success message
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File downloaded successfully: ${widget.fileName}'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Open',
                onPressed: () => _openDownloadedFile(savedPath),
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });

        // Show error message
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
  }

  Future<void> _openDownloadedFile(String filePath) async {
    try {
      await FileUtils.openFile(filePath);
    } catch (error) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          error,
        );
      }
    }
  }

  Future<void> _previewFile() async {
    if (_tempFilePath != null && File(_tempFilePath!).existsSync()) {
      // File is already downloaded, open it directly
      widget.onPreview?.call();
      return;
    }

    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      // Download file for preview with progress tracking
      final file = await FileUtils.saveFileFromUrl(
        widget.fileUrl,
        widget.fileName,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      // Store the temporary file path
      _tempFilePath = file.path;

      setState(() {
        _isDownloading = false;
      });

      // Call the preview callback
      widget.onPreview?.call();
    } catch (error) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });

        // Show error message with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error preparing file for preview: ${error.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _previewFile,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extension =
        path.extension(widget.fileName).replaceAll('.', '').toUpperCase();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // File icon and name
            Row(
              children: [
                _FileTypeIcon(extension: extension),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fileName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.description!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress indicator when downloading
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Downloading... ${(_downloadProgress * 100).toInt()}%',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],

            const Divider(),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.onPreview != null)
                  Expanded(
                    child: AppButton(
                      label: 'Preview',
                      icon: Icons.visibility,
                      onPressed: _previewFile,
                      isDisabled: _isDownloading,
                      type: AppButtonType.outline,
                    ),
                  ),
                if (widget.onPreview != null) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: _fileDownloaded ? 'Download Again' : 'Download',
                    icon: _isDownloading ? null : Icons.download,
                    onPressed: _downloadFile,
                    isLoading: _isDownloading,
                    isDisabled: _isDownloading,
                    type: AppButtonType.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FileTypeIcon extends StatelessWidget {
  final String extension;

  const _FileTypeIcon({required this.extension});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    final IconData icon;

    // Determine the icon and colors based on file extension
    switch (extension.toLowerCase()) {
      case 'pdf':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.picture_as_pdf;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.image;
        break;
      case 'doc':
      case 'docx':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.description;
        break;
      case 'xls':
      case 'xlsx':
      case 'csv':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.table_chart;
        break;
      case 'ppt':
      case 'pptx':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.slideshow;
        break;
      case 'txt':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.text_snippet;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.insert_drive_file;
        break;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            extension.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

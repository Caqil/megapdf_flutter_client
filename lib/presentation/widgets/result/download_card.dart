// lib/presentation/widgets/result/download_card.dart

import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';
import 'package:path/path.dart' as path;

class DownloadCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extension =
        path.extension(fileName).replaceAll('.', '').toUpperCase();

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
                        fileName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
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
            const Divider(),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onPreview != null)
                  Expanded(
                    child: AppButton(
                      label: 'Preview',
                      icon: Icons.visibility,
                      onPressed: onPreview!,
                      isDisabled: isDownloading,
                      type: AppButtonType.outline,
                    ),
                  ),
                if (onPreview != null) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Download',
                    icon: isDownloading ? null : Icons.download,
                    onPressed: onDownload,
                    isLoading: isDownloading,
                    isDisabled: isDownloading,
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

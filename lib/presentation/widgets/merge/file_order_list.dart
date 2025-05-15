// lib/presentation/widgets/merge/file_order_list.dart

import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/theme/app_theme.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';

class FileOrderList extends StatelessWidget {
  final List<PdfFile> files;
  final Function(int) onDelete;
  final Function(int, int) onReorder;

  const FileOrderList({
    super.key,
    required this.files,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final file = files[index];
        return _FileListItem(
          key: ValueKey(file.name + index.toString()),
          file: file,
          index: index + 1,
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}

class _FileListItem extends StatelessWidget {
  final PdfFile file;
  final int index;
  final VoidCallback onDelete;

  const _FileListItem({
    required Key key,
    required this.file,
    required this.index,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              index.toString(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          file.name,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          file.formattedSize,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reorder handle
            const Icon(
              Icons.drag_handle,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: onDelete,
              tooltip: 'Remove file',
            ),
          ],
        ),
      ),
    );
  }
}

// A more advanced version with page preview support
class AdvancedFileOrderList extends StatelessWidget {
  final List<PdfFile> files;
  final Function(int) onDelete;
  final Function(int, int) onReorder;
  final Function(int)? onPreview;
  final bool showPageCount;

  const AdvancedFileOrderList({
    super.key,
    required this.files,
    required this.onDelete,
    required this.onReorder,
    this.onPreview,
    this.showPageCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final file = files[index];
        return _AdvancedFileListItem(
          key: ValueKey(file.name + index.toString()),
          file: file,
          index: index + 1,
          onDelete: () => onDelete(index),
          onPreview: onPreview != null ? () => onPreview!(index) : null,
          showPageCount: showPageCount,
        );
      },
    );
  }
}

class _AdvancedFileListItem extends StatelessWidget {
  final PdfFile file;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback? onPreview;
  final bool showPageCount;

  const _AdvancedFileListItem({
    required Key key,
    required this.file,
    required this.index,
    required this.onDelete,
    this.onPreview,
    this.showPageCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // File index indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // PDF icon
            const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
            const SizedBox(width: 12),

            // File details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        file.formattedSize,
                        style: theme.textTheme.bodySmall,
                      ),
                      if (showPageCount && file.pageCount != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.pages, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${file.pageCount} pages',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onPreview != null)
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    onPressed: onPreview,
                    tooltip: 'Preview',
                    color: theme.colorScheme.primary,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: 'Remove',
                  color: AppColors.error,
                ),
                // Reorder handle
                const Icon(
                  Icons.drag_handle,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

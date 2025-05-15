// lib/presentation/screens/merge/merge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/core/error/error_handler.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';
import 'package:megapdf_flutter_client/core/widgets/app_loading.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/presentation/router/route_names.dart';
import 'package:megapdf_flutter_client/presentation/widgets/common/file_picker_button.dart';
import 'package:megapdf_flutter_client/presentation/widgets/merge/file_order_list.dart';
import 'package:megapdf_flutter_client/providers/merge_provider.dart';

class MergeScreen extends ConsumerStatefulWidget {
  const MergeScreen({super.key});

  @override
  ConsumerState<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends ConsumerState<MergeScreen> {
  final List<PdfFile> _selectedFiles = [];
  bool _isMerging = false;

  void _addFiles(List<PdfFile> files) {
    setState(() {
      _selectedFiles.addAll(files);
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _selectedFiles.removeAt(oldIndex);
      _selectedFiles.insert(newIndex, item);
    });
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _mergePdfs() async {
    if (_selectedFiles.isEmpty || _selectedFiles.length < 2) {
      ErrorHandler.showErrorSnackBar(
        context,
        AppError(
          message: 'Please select at least 2 PDF files to merge',
          type: AppErrorType.validation,
        ),
      );
      return;
    }

    setState(() {
      _isMerging = true;
    });

    try {
      final result = await ref.read(mergeProvider.notifier).mergePdfs(
            files: _selectedFiles,
          );

      if (!mounted) return;

      // Navigate to result screen
      context.pushReplacement(
        RouteNames.resultPath,
        extra: {
          'operation': AppConstants.operationMerge,
          'fileUrl': result.fileUrl,
          'fileName': result.filename,
          'mergedSize': result.mergedSize,
          'totalInputSize': result.totalInputSize,
          'fileCount': result.fileCount,
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isMerging = false;
      });

      ErrorHandler.showErrorDialog(
        context,
        error,
        onRetry: _mergePdfs,
      );
    }
  }

  void _showAddFilesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add PDF Files'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MultiplePdfPickerButton(
              onFilesPicked: (files) {
                _addFiles(files);
                Navigator.pop(context);
              },
              buttonText: 'Select Multiple PDFs',
              icon: Icons.upload_file,
              fullWidth: true,
            ),
            const SizedBox(height: 16),
            PdfPickerButton(
              onFilePicked: (file) {
                _addFiles([file]);
                Navigator.pop(context);
              },
              buttonText: 'Select Single PDF',
              icon: Icons.picture_as_pdf,
              fullWidth: true,
              buttonType: AppButtonType.outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDFs'),
      ),
      body: AppLoadingOverlay(
        isLoading: _isMerging,
        message: 'Merging PDFs...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and info
              Text(
                'Combine multiple PDFs',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Select multiple PDF files and combine them into a single document. '
                'You can rearrange the order of files to define how they appear in the final PDF.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // File selection area
              if (_selectedFiles.isEmpty) ...[
                DragDropFileUpload(
                  onFilePicked: (file) => _addFiles([file]),
                  allowedExtensions: AppConstants.pdfExtensions,
                  prompt: 'Select or drop PDF files',
                  dropHint: 'You can add multiple files',
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                Center(
                  child: MultiplePdfPickerButton(
                    onFilesPicked: _addFiles,
                    buttonText: 'Select Multiple PDFs',
                    icon: Icons.upload_file,
                  ),
                ),
              ] else ...[
                // File list with reordering
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selected Files (${_selectedFiles.length})',
                              style: theme.textTheme.titleMedium,
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add More'),
                                  onPressed: () => _showAddFilesDialog(context),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  label: const Text('Clear All'),
                                  onPressed: _clearFiles,
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Drag and drop files to reorder them',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        FileOrderList(
                          files: _selectedFiles,
                          onDelete: _removeFile,
                          onReorder: _reorderFiles,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Merge button
                AppButton(
                  label: 'Merge PDFs',
                  onPressed: _mergePdfs,
                  isLoading: _isMerging,
                  isDisabled: _isMerging,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  icon: Icons.merge_type,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

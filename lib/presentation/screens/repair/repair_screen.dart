// lib/presentation/screens/repair/repair_screen.dart

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
import 'package:megapdf_flutter_client/providers/repair_provider.dart';

class RepairScreen extends ConsumerStatefulWidget {
  const RepairScreen({super.key});

  @override
  ConsumerState<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends ConsumerState<RepairScreen> {
  PdfFile? _selectedFile;
  bool _isRepairing = false;

  void _selectFile(PdfFile file) {
    setState(() {
      _selectedFile = file;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _repairPdf() async {
    if (_selectedFile == null) {
      ErrorHandler.showErrorSnackBar(
        context,
        AppError(
          message: 'Please select a PDF file first',
          type: AppErrorType.validation,
        ),
      );
      return;
    }

    setState(() {
      _isRepairing = true;
    });

    try {
      final result = await ref.read(repairProvider.notifier).repairPdf(
            file: _selectedFile!,
          );

      if (!mounted) return;

      // Navigate to result screen
      context.pushReplacement(
        RouteNames.resultPath,
        extra: {
          'operation': AppConstants.operationRepair,
          'fileUrl': result.fileUrl,
          'fileName': result.filename,
          'originalName': result.originalName,
          'details': result.details,
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isRepairing = false;
      });

      ErrorHandler.showErrorDialog(
        context,
        error,
        onRetry: _repairPdf,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair PDF'),
      ),
      body: AppLoadingOverlay(
        isLoading: _isRepairing,
        message: 'Repairing PDF...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and info
              Text(
                'Fix corrupted PDF files',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Repair corrupt or damaged PDF files and recover content when possible.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // File selection area
              if (_selectedFile == null) ...[
                DragDropFileUpload(
                  onFilePicked: _selectFile,
                  allowedExtensions: AppConstants.pdfExtensions,
                  prompt: 'Select or drop a corrupted PDF file',
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                Center(
                  child: PdfPickerButton(
                    onFilePicked: _selectFile,
                    buttonText: 'Select PDF File',
                    icon: Icons.picture_as_pdf,
                  ),
                ),
              ] else ...[
                _SelectedFileCard(
                  file: _selectedFile!,
                  onRemove: _resetForm,
                ),
                const SizedBox(height: 24),

                // Repair info card
                Card(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How PDF Repair Works',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          context,
                          title: 'Analyze Structure',
                          description:
                              'Our tool analyzes the structure of your PDF file to identify corruption issues.',
                          icon: Icons.search,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          title: 'Fix Objects',
                          description:
                              'Damaged PDF objects are repaired when possible.',
                          icon: Icons.build,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          title: 'Recover Content',
                          description:
                              'Text, images and other content are extracted and preserved.',
                          icon: Icons.restore_page,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          title: 'Rebuild File',
                          description:
                              'A new, working PDF file is created from the recovered content.',
                          icon: Icons.file_download,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Repair button
                AppButton(
                  label: 'Repair PDF',
                  onPressed: _repairPdf,
                  isLoading: _isRepairing,
                  isDisabled: _isRepairing,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  icon: Icons.build,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedFileCard extends StatelessWidget {
  final PdfFile file;
  final VoidCallback onRemove;

  const _SelectedFileCard({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, size: 32, color: Colors.red),
              const SizedBox(width: 12),
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
                    Text(
                      file.formattedSize,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onRemove,
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

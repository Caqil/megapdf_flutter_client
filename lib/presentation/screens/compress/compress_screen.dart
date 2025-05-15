import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/core/error/error_handler.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';
import 'package:megapdf_flutter_client/core/widgets/app_loading.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/presentation/router/route_names.dart';
import 'package:megapdf_flutter_client/presentation/widgets/common/file_picker_button.dart';
import 'package:megapdf_flutter_client/presentation/widgets/compress/quality_selector.dart';
import 'package:megapdf_flutter_client/providers/compress_provider.dart';

class CompressScreen extends ConsumerStatefulWidget {
  const CompressScreen({super.key});

  @override
  ConsumerState<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends ConsumerState<CompressScreen> {
  PdfFile? _selectedFile;
  int _quality = AppConstants.defaultCompressionQuality;
  bool _isCompressing = false;

  void _selectFile(PdfFile file) {
    setState(() {
      _selectedFile = file;
    });
  }

  void _updateQuality(int quality) {
    setState(() {
      _quality = quality;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _quality = AppConstants.defaultCompressionQuality;
    });
  }

  Future<void> _compressPdf() async {
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
      _isCompressing = true;
    });

    try {
      final result = await ref.read(compressProvider.notifier).compressPdf(
            file: _selectedFile!,
            quality: _quality,
          );

      if (!mounted) return;

      // Navigate to result screen
      context.pushReplacement(
        RouteNames.resultPath,
        extra: {
          'operation': AppConstants.operationCompress,
          'fileUrl': result.fileUrl,
          'fileName': result.filename,
          'originalName': result.originalName,
          'originalSize': result.originalSize,
          'compressedSize': result.compressedSize,
          'compressionRatio': result.compressionRatio,
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isCompressing = false;
      });

      ErrorHandler.showErrorDialog(
        context,
        error,
        onRetry: _compressPdf,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
      ),
      body: AppLoadingOverlay(
        isLoading: _isCompressing,
        message: 'Compressing PDF...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and info
              Text(
                'Reduce PDF file size',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Compress your PDF documents to save storage space and make it easier to share.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // File selection area
              if (_selectedFile == null) ...[
                DragDropFileUpload(
                  onFilePicked: _selectFile,
                  allowedExtensions: AppConstants.pdfExtensions,
                  prompt: 'Select or drop a PDF file',
                  dropHint:
                      'Supports PDF files up to ${FileUtils.getFormattedFileSize(AppConstants.maxFileSize)}',
                  fullWidth: true,
                ),
              ] else ...[
                _SelectedFileCard(
                  file: _selectedFile!,
                  onRemove: _resetForm,
                ),
              ],
              const SizedBox(height: 24),

              // Compression options
              if (_selectedFile != null) ...[
                Text(
                  'Compression Quality',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Adjust the quality to control the level of compression. Lower quality means smaller file size.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                QualitySelector(
                  quality: _quality,
                  onChanged: _updateQuality,
                ),
                const SizedBox(height: 24),

                // Compress button
                AppButton(
                  label: 'Compress PDF',
                  onPressed: _compressPdf,
                  isLoading: _isCompressing,
                  isDisabled: _isCompressing,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  icon: Icons.compress,
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

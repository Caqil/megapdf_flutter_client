// lib/presentation/screens/convert/convert_screen.dart

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
import 'package:megapdf_flutter_client/presentation/widgets/convert/format_selector.dart';
import 'package:megapdf_flutter_client/providers/convert_provider.dart';

class ConvertScreen extends ConsumerStatefulWidget {
  const ConvertScreen({super.key});

  @override
  ConsumerState<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends ConsumerState<ConvertScreen> {
  PdfFile? _selectedFile;
  String _targetFormat = AppConstants.defaultConversionFormat;
  bool _isConverting = false;

  final List<String> _pdfToOtherFormats = ['docx', 'jpg', 'png', 'txt', 'html'];

  final List<String> _otherToPdfFormats = ['pdf'];

  void _selectFile(PdfFile file) {
    setState(() {
      _selectedFile = file;

      // If the file is not a PDF, automatically set the target format to PDF
      if (!file.isPdf) {
        _targetFormat = 'pdf';
      }
    });
  }

  void _updateFormat(String format) {
    setState(() {
      _targetFormat = format;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _targetFormat = AppConstants.defaultConversionFormat;
    });
  }

  // Get allowed file extensions based on conversion direction
  List<String> _getAllowedExtensions() {
    // If converting to PDF, accept document, image, and spreadsheet formats
    if (_targetFormat == 'pdf') {
      return [
        ...AppConstants.documentExtensions,
        ...AppConstants.imageExtensions,
        ...AppConstants.spreadsheetExtensions,
        ...AppConstants.presentationExtensions,
      ];
    } else {
      // If converting from PDF to other format, accept only PDFs
      return AppConstants.pdfExtensions;
    }
  }

  // Get list of target formats based on selected file
  List<String> _getTargetFormats() {
    if (_selectedFile == null) {
      return _pdfToOtherFormats;
    }

    if (_selectedFile!.isPdf) {
      return _pdfToOtherFormats;
    } else {
      return _otherToPdfFormats;
    }
  }

  Future<void> _convertFile() async {
    if (_selectedFile == null) {
      ErrorHandler.showErrorSnackBar(
        context,
        AppError(
          message: 'Please select a file to convert',
          type: AppErrorType.validation,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
    });

    try {
      final result = await ref.read(convertProvider.notifier).convertFile(
            file: _selectedFile!,
            outputFormat: _targetFormat,
          );

      if (!mounted) return;

      // Navigate to result screen
      context.pushReplacement(
        RouteNames.resultPath,
        extra: {
          'operation': AppConstants.operationConvert,
          'fileUrl': result.fileUrl,
          'fileName': result.filename,
          'originalName': result.originalName,
          'inputFormat': result.inputFormat,
          'outputFormat': result.outputFormat,
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isConverting = false;
      });

      ErrorHandler.showErrorDialog(
        context,
        error,
        onRetry: _convertFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetFormats = _getTargetFormats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert Files'),
      ),
      body: AppLoadingOverlay(
        isLoading: _isConverting,
        message: 'Converting file...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and info
              Text(
                'Convert between formats',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Convert PDF documents to other formats or convert various file types to PDF.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // File selection area
              if (_selectedFile == null) ...[
                DragDropFileUpload(
                  onFilePicked: _selectFile,
                  allowedExtensions: _getAllowedExtensions(),
                  prompt: 'Select or drop a file',
                  dropHint:
                      'Supports various formats including PDF, DOCX, JPG, PNG, and more',
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                Center(
                  child: FilePickerButton(
                    onFilePicked: _selectFile,
                    allowedExtensions: _getAllowedExtensions(),
                    buttonText: 'Select File',
                    icon: Icons.upload_file,
                  ),
                ),
              ] else ...[
                _SelectedFileCard(
                  file: _selectedFile!,
                  onRemove: _resetForm,
                ),
                const SizedBox(height: 24),

                // Format selection
                Text(
                  'Output Format',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the format you want to convert your file to.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                FormatSelector(
                  selectedFormat: _targetFormat,
                  formats: targetFormats,
                  onFormatChanged: _updateFormat,
                ),
                const SizedBox(height: 24),

                // Convert button
                AppButton(
                  label: 'Convert File',
                  onPressed: _convertFile,
                  isLoading: _isConverting,
                  isDisabled: _isConverting,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  icon: Icons.transform,
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
    final extension = file.extension?.toUpperCase() ?? '';

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
              _buildFileTypeIcon(extension),
              const SizedBox(width: 16),
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
                      '${file.formattedSize} • ${extension.isEmpty ? 'Unknown' : extension} File',
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

  Widget _buildFileTypeIcon(String extension) {
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
      width: 48,
      height: 48,
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
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            extension.isEmpty ? 'FILE' : extension,
            style: TextStyle(
              color: textColor,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

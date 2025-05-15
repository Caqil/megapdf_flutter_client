// lib/presentation/screens/convert/convert_screen.dart

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
import 'package:megapdf_flutter_client/presentation/widgets/convert/format_selector.dart';
import 'package:megapdf_flutter_client/providers/convert_provider.dart';

// Enum to represent different conversion types
enum ConversionType {
  imageToPdf,
  officeToPdf,
  pdfToImage,
  pdfToOffice,
}

class ConvertScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? params;

  const ConvertScreen({super.key, this.params});

  @override
  ConsumerState<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends ConsumerState<ConvertScreen> {
  PdfFile? _selectedFile;
  String _outputFormat = '';
  bool _isConverting = false;
  int _currentStep = 0;

  // Default conversion type
  ConversionType _conversionType = ConversionType.pdfToImage;

  // Format options for each conversion type
  final Map<ConversionType, List<String>> _formatOptions = {
    ConversionType.pdfToImage: ['jpg', 'png', 'tiff'],
    ConversionType.pdfToOffice: ['docx', 'xlsx', 'pptx', 'txt'],
    ConversionType.imageToPdf: ['pdf'],
    ConversionType.officeToPdf: ['pdf'],
  };

  // Input extensions for each conversion type
  final Map<ConversionType, List<String>> _inputExtensions = {
    ConversionType.pdfToImage: AppConstants.pdfExtensions,
    ConversionType.pdfToOffice: AppConstants.pdfExtensions,
    ConversionType.imageToPdf: AppConstants.imageExtensions,
    ConversionType.officeToPdf: [
      ...AppConstants.documentExtensions,
      ...AppConstants.spreadsheetExtensions,
      ...AppConstants.presentationExtensions,
    ],
  };

  @override
  void initState() {
    super.initState();
    _determineConversionType();
    _setDefaultOutputFormat();
  }

  void _determineConversionType() {
    if (widget.params != null && widget.params!.containsKey('type')) {
      final type = widget.params!['type'];

      switch (type) {
        case 'image_to_pdf':
          _conversionType = ConversionType.imageToPdf;
          break;
        case 'office_to_pdf':
          _conversionType = ConversionType.officeToPdf;
          break;
        case 'pdf_to_image':
        case 'pdf_to_jpg':
          _conversionType = ConversionType.pdfToImage;
          break;
        case 'pdf_to_office':
          _conversionType = ConversionType.pdfToOffice;
          break;
      }
    }
  }

  void _setDefaultOutputFormat() {
    // Set default output format based on conversion type
    switch (_conversionType) {
      case ConversionType.pdfToImage:
        _outputFormat = 'jpg';
        break;
      case ConversionType.pdfToOffice:
        _outputFormat = 'docx';
        break;
      case ConversionType.imageToPdf:
      case ConversionType.officeToPdf:
        _outputFormat = 'pdf';
        break;
    }
  }

  void _selectFile(PdfFile file) {
    setState(() {
      _selectedFile = file;
      _currentStep = 1;
    });
  }

  void _updateOutputFormat(String format) {
    setState(() {
      _outputFormat = format;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _currentStep = 0;
      _setDefaultOutputFormat();
    });
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
            outputFormat: _outputFormat,
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

  String _getTitle() {
    switch (_conversionType) {
      case ConversionType.pdfToImage:
        return 'PDF to Image';
      case ConversionType.pdfToOffice:
        return 'PDF to Office';
      case ConversionType.imageToPdf:
        return 'Image to PDF';
      case ConversionType.officeToPdf:
        return 'Office to PDF';
    }
  }

  String _getDescription() {
    switch (_conversionType) {
      case ConversionType.pdfToImage:
        return 'Convert your PDF documents to image formats.';
      case ConversionType.pdfToOffice:
        return 'Convert PDF documents to editable Office formats.';
      case ConversionType.imageToPdf:
        return 'Convert images to PDF format for better sharing.';
      case ConversionType.officeToPdf:
        return 'Convert Office documents to PDF format.';
    }
  }

  String _getSelectPrompt() {
    switch (_conversionType) {
      case ConversionType.pdfToImage:
      case ConversionType.pdfToOffice:
        return 'Select a PDF file to convert';
      case ConversionType.imageToPdf:
        return 'Select an image file to convert';
      case ConversionType.officeToPdf:
        return 'Select an Office document to convert';
    }
  }

  String _getButtonText() {
    switch (_conversionType) {
      case ConversionType.pdfToImage:
        return 'Select PDF';
      case ConversionType.pdfToOffice:
        return 'Select PDF';
      case ConversionType.imageToPdf:
        return 'Select Image';
      case ConversionType.officeToPdf:
        return 'Select Document';
    }
  }

  IconData _getButtonIcon() {
    switch (_conversionType) {
      case ConversionType.pdfToImage:
      case ConversionType.pdfToOffice:
        return Icons.picture_as_pdf;
      case ConversionType.imageToPdf:
        return Icons.image;
      case ConversionType.officeToPdf:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: AppLoadingOverlay(
        isLoading: _isConverting,
        message: 'Converting file...',
        child: Stepper(
          currentStep: _currentStep,
          controlsBuilder: (context, details) {
            return const SizedBox.shrink(); // Hide default controls
          },
          steps: [
            // Step 1: Select file
            Step(
              title: const Text('Select File'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDescription(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (_selectedFile == null) ...[
                      DragDropFileUpload(
                        onFilePicked: _selectFile,
                        allowedExtensions:
                            _inputExtensions[_conversionType] ?? [],
                        prompt: _getSelectPrompt(),
                        dropHint: 'or click to select',
                        fullWidth: true,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: FilePickerButton(
                          onFilePicked: _selectFile,
                          allowedExtensions:
                              _inputExtensions[_conversionType] ?? [],
                          buttonText: _getButtonText(),
                          icon: _getButtonIcon(),
                        ),
                      ),
                    ] else ...[
                      _SelectedFileCard(
                        file: _selectedFile!,
                        onRemove: _resetForm,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Continue',
                        onPressed: () => setState(() => _currentStep = 1),
                        type: AppButtonType.primary,
                        fullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),

            // Step 2: Choose output format
            Step(
              title: const Text('Choose Format'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    selectedFormat: _outputFormat,
                    formats: _formatOptions[_conversionType] ?? ['pdf'],
                    onFormatChanged: _updateOutputFormat,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Back',
                          onPressed: () => setState(() => _currentStep = 0),
                          type: AppButtonType.outline,
                          fullWidth: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          label: 'Convert',
                          onPressed: _convertFile,
                          isLoading: _isConverting,
                          isDisabled: _isConverting,
                          type: AppButtonType.primary,
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
          ],
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

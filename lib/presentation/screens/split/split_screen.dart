// lib/presentation/screens/split/split_screen.dart

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
import 'package:megapdf_flutter_client/presentation/widgets/split/page_range_selector.dart';
import 'package:megapdf_flutter_client/providers/split_provider.dart';

class SplitScreen extends ConsumerStatefulWidget {
  const SplitScreen({super.key});

  @override
  ConsumerState<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends ConsumerState<SplitScreen> {
  PdfFile? _selectedFile;
  bool _isSplitting = false;
  int _pageCount = 0;
  bool _isLoadingPageCount = false;
  String _splitOption = 'custom';
  final _pageRangeController = TextEditingController();
  bool _extractAllPages = false;

  @override
  void dispose() {
    _pageRangeController.dispose();
    super.dispose();
  }

  void _selectFile(PdfFile file) async {
    setState(() {
      _selectedFile = file;
      _isLoadingPageCount = true;
    });

    try {
      // Load page count for the selected PDF
      final pageCount =
          await ref.read(splitProvider.notifier).getPageCount(file);
      if (!mounted) return;

      setState(() {
        _pageCount = pageCount;
        _isLoadingPageCount = false;
        _pageRangeController.text = '1-$pageCount';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingPageCount = false;
      });

      ErrorHandler.showErrorSnackBar(
        context,
        error,
      );
    }
  }

  void _updateSplitOption(String option) {
    setState(() {
      _splitOption = option;

      // Reset page range input based on selected option
      if (option == 'all') {
        _extractAllPages = true;
      } else {
        _extractAllPages = false;

        // Set default page range based on option
        if (option == 'custom') {
          _pageRangeController.text = '1-$_pageCount';
        } else if (option == 'single') {
          _pageRangeController.text = '1';
        } else if (option == 'even') {
          final evenPages = <int>[];
          for (int i = 2; i <= _pageCount; i += 2) {
            evenPages.add(i);
          }
          _pageRangeController.text = evenPages.join(',');
        } else if (option == 'odd') {
          final oddPages = <int>[];
          for (int i = 1; i <= _pageCount; i += 2) {
            oddPages.add(i);
          }
          _pageRangeController.text = oddPages.join(',');
        }
      }
    });
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _pageCount = 0;
      _splitOption = 'custom';
      _pageRangeController.text = '';
      _extractAllPages = false;
    });
  }

  Future<void> _splitPdf() async {
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

    if (_pageCount == 0) {
      ErrorHandler.showErrorSnackBar(
        context,
        AppError(
          message: 'Unable to determine page count of the PDF file',
          type: AppErrorType.validation,
        ),
      );
      return;
    }

    // Determine which pages to extract
    final List<int> pagesToExtract = [];

    if (_extractAllPages) {
      // Extract all pages as individual files
      for (int i = 1; i <= _pageCount; i++) {
        pagesToExtract.add(i);
      }
    } else {
      // Parse page ranges from input
      if (_pageRangeController.text.trim().isEmpty) {
        ErrorHandler.showErrorSnackBar(
          context,
          AppError(
            message: 'Please specify which pages to extract',
            type: AppErrorType.validation,
          ),
        );
        return;
      }

      try {
        pagesToExtract.addAll(
          _parsePageRanges(_pageRangeController.text, _pageCount),
        );
      } catch (e) {
        ErrorHandler.showErrorSnackBar(
          context,
          AppError(
            message:
                'Invalid page range format. Please use format like: 1-3,5,7-9',
            type: AppErrorType.validation,
          ),
        );
        return;
      }

      if (pagesToExtract.isEmpty) {
        ErrorHandler.showErrorSnackBar(
          context,
          AppError(
            message: 'No valid pages specified for extraction',
            type: AppErrorType.validation,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSplitting = true;
    });

    try {
      final result = await ref.read(splitProvider.notifier).splitPdf(
            file: _selectedFile!,
            pages: pagesToExtract,
            extractAsIndividualFiles: _extractAllPages,
          );

      if (!mounted) return;

      // Navigate to result screen
      context.pushReplacement(
        RouteNames.resultPath,
        extra: {
          'operation': AppConstants.operationSplit,
          'fileUrl': result.splitParts!.first.fileUrl,
          'fileName': result.splitParts!.first.filename,
          'totalPages': result.totalPages,
          'splitParts': result.splitParts,
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSplitting = false;
      });

      ErrorHandler.showErrorDialog(
        context,
        error,
        onRetry: _splitPdf,
      );
    }
  }

  // Parse page ranges from string input (e.g., "1-3,5,7-9")
  List<int> _parsePageRanges(String input, int maxPages) {
    final pages = <int>{};
    final ranges = input.split(',');

    for (final range in ranges) {
      final trimmedRange = range.trim();

      if (trimmedRange.isEmpty) continue;

      if (trimmedRange.contains('-')) {
        final parts = trimmedRange.split('-');
        if (parts.length != 2) {
          throw FormatException('Invalid range format: $trimmedRange');
        }

        final start = int.tryParse(parts[0].trim());
        final end = int.tryParse(parts[1].trim());

        if (start == null || end == null) {
          throw FormatException('Invalid numbers in range: $trimmedRange');
        }

        if (start < 1 || end > maxPages || start > end) {
          throw FormatException('Invalid page range: $trimmedRange');
        }

        for (var i = start; i <= end; i++) {
          pages.add(i);
        }
      } else {
        final page = int.tryParse(trimmedRange);
        if (page == null || page < 1 || page > maxPages) {
          throw FormatException('Invalid page number: $trimmedRange');
        }
        pages.add(page);
      }
    }

    return pages.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
      ),
      body: AppLoadingOverlay(
        isLoading: _isSplitting,
        message: 'Splitting PDF...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and info
              Text(
                'Extract pages from PDF',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a PDF file and choose which pages to extract. You can extract specific pages, ranges, or split the entire document.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // File selection area
              if (_selectedFile == null) ...[
                DragDropFileUpload(
                  onFilePicked: _selectFile,
                  allowedExtensions: AppConstants.pdfExtensions,
                  prompt: 'Select or drop a PDF file',
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
                  pageCount: _pageCount,
                  isLoadingPageCount: _isLoadingPageCount,
                  onRemove: _resetForm,
                ),
                const SizedBox(height: 24),
                if (!_isLoadingPageCount && _pageCount > 0) ...[
                  // Split options
                  Text(
                    'Extract Pages',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select how you want to split the PDF',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Split options selector
                  _SplitOptionsSelector(
                    selectedOption: _splitOption,
                    onOptionChanged: _updateSplitOption,
                  ),
                  const SizedBox(height: 24),

                  // Page range input (when not selecting "Extract All Pages")
                  if (!_extractAllPages) ...[
                    Text(
                      'Page Range',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Specify which pages to extract (e.g., 1-3,5,7-9)',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    PageRangeSelector(
                      controller: _pageRangeController,
                      pageCount: _pageCount,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total pages: $_pageCount',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Split button
                  AppButton(
                    label: 'Split PDF',
                    onPressed: _splitPdf,
                    isLoading: _isSplitting,
                    isDisabled: _isSplitting || _isLoadingPageCount,
                    type: AppButtonType.primary,
                    size: AppButtonSize.large,
                    icon: Icons.call_split,
                    fullWidth: true,
                  ),
                ],
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
  final int pageCount;
  final bool isLoadingPageCount;
  final VoidCallback onRemove;

  const _SelectedFileCard({
    required this.file,
    required this.pageCount,
    required this.isLoadingPageCount,
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
                      '${file.formattedSize} • ${isLoadingPageCount ? 'Loading pages...' : '$pageCount pages'}',
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
          if (isLoadingPageCount) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ],
        ],
      ),
    );
  }
}

class _SplitOptionsSelector extends StatelessWidget {
  final String selectedOption;
  final Function(String) onOptionChanged;

  const _SplitOptionsSelector({
    required this.selectedOption,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildOptionTile(
          context,
          option: 'custom',
          title: 'Custom Range',
          subtitle: 'Extract specific pages or ranges',
          icon: Icons.format_list_numbered,
        ),
        const SizedBox(height: 8),
        _buildOptionTile(
          context,
          option: 'all',
          title: 'Extract All Pages',
          subtitle: 'Split into individual PDF files',
          icon: Icons.file_copy,
        ),
        const SizedBox(height: 8),
        _buildOptionTile(
          context,
          option: 'single',
          title: 'Extract Single Page',
          subtitle: 'Extract one specific page',
          icon: Icons.filter_1,
        ),
        const SizedBox(height: 8),
        _buildOptionTile(
          context,
          option: 'even',
          title: 'Even Pages',
          subtitle: 'Extract all even-numbered pages',
          icon: Icons.filter_2,
        ),
        const SizedBox(height: 8),
        _buildOptionTile(
          context,
          option: 'odd',
          title: 'Odd Pages',
          subtitle: 'Extract all odd-numbered pages',
          icon: Icons.filter_3,
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String option,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedOption == option;

    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withOpacity(0.1)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onOptionChanged(option),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: option,
                groupValue: selectedOption,
                onChanged: (value) {
                  if (value != null) {
                    onOptionChanged(value);
                  }
                },
                activeColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

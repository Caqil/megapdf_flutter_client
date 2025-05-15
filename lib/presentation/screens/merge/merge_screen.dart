// lib/presentation/screens/merge/merge_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/core/error/error_handler.dart';
import 'package:megapdf_flutter_client/core/theme/app_theme.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:megapdf_flutter_client/core/widgets/animated_progress_stepper.dart';
import 'package:megapdf_flutter_client/core/widgets/gradient_button.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/presentation/router/route_names.dart';
import 'package:megapdf_flutter_client/presentation/widgets/common/file_picker_button.dart';
import 'package:megapdf_flutter_client/providers/merge_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MergeScreen extends ConsumerStatefulWidget {
  const MergeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends ConsumerState<MergeScreen> {
  final List<PdfFile> _selectedFiles = [];
  bool _isMerging = false;
  int _currentStep = 0;
  bool _canContinue = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDFs'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientAlt1, AppColors.gradientAlt2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Hero(
          tag: 'merge-card',
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: AnimatedProgressStepper(
        steps: [
          ProgressStep(
            title: 'Select Files',
            icon: Icons.file_copy,
            content: _buildFileSelectionStep(),
          ),
          ProgressStep(
            title: 'Arrange',
            icon: Icons.sort,
            content: _buildFileOrderStep(),
          ),
          ProgressStep(
            title: 'Merge',
            icon: Icons.merge_type,
            content: _buildMergeProgressStep(),
          ),
        ],
        currentStep: _currentStep,
        onStepTapped: (step) {
          // Allow going back to previous steps only
          if (step < _currentStep) {
            setState(() {
              _currentStep = step;
            });
          }
        },
        onContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep++;

              // Reset can continue for the next step
              if (_currentStep == 1) {
                _canContinue = _selectedFiles.length >= 2;
              } else if (_currentStep == 2) {
                _mergePdfs();
              }
            });
          }
        },
        onCancel: () {
          setState(() {
            _currentStep--;
          });
        },
        canContinue: _canContinue,
      ),
    );
  }

  Widget _buildFileSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select PDFs to merge',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose multiple PDF files that you want to combine into a single document.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // File selection area
          Center(
            child: Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _selectFiles,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/upload_files.json',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to select PDF files',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'or drag and drop here',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Maximum ${AppConstants.maxFilesForMerge} files, ${FileUtils.getFormattedFileSize(AppConstants.maxFileSize)} each',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 24),

          // Selected files display
          if (_selectedFiles.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Files (${_selectedFiles.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _clearFiles,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  return _FileListItem(
                    file: file,
                    index: index + 1,
                    onDelete: () => _removeFile(index),
                  );
                },
              ),
            ),
          ] else ...[
            const Spacer(),
            Center(
              child: GradientButton(
                label: 'Select PDF Files',
                icon: Icons.add,
                onPressed: _selectFiles,
                gradientColors: const [
                  AppColors.gradientAlt1,
                  AppColors.gradientAlt2
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFileOrderStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arrange Your PDFs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Drag and drop to rearrange the order of your PDF files. The final document will follow this sequence.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ReorderableListView.builder(
              itemCount: _selectedFiles.length,
              onReorder: _reorderFiles,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return _ReorderableFileCard(
                  key: ValueKey(file.path + index.toString()),
                  file: file,
                  index: index + 1,
                  onDelete: () => _removeFile(index),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Merge info card
          _FileCountInfoCard(
            fileCount: _selectedFiles.length,
            totalSize: _calculateTotalSize(),
          ),
        ],
      ),
    );
  }

  Widget _buildMergeProgressStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isMerging) ...[
            Lottie.asset(
              'assets/animations/merging.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              'Merging PDFs...',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gradientAlt1),
            ),
            const SizedBox(height: 16),
            Text(
              'Please wait while we combine your files',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Icon(
              Icons.merge_type,
              color: AppColors.gradientAlt1,
              size: 100,
            ),
            const SizedBox(height: 32),
            Text(
              'Ready to Merge',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your ${_selectedFiles.length} files will be combined in the order shown',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GradientButton(
              label: 'Merge PDFs',
              icon: Icons.merge_type,
              onPressed: _mergePdfs,
              isLoading: _isMerging,
              fullWidth: true,
              size: GradientButtonSize.large,
              gradientColors: const [
                AppColors.gradientAlt1,
                AppColors.gradientAlt2
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectFiles() async {
    try {
      final files = await FileUtils.pickMultiplePdfFiles(
        maxFiles: AppConstants.maxFilesForMerge,
      );

      if (files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(files);
          _canContinue = _selectedFiles.length >= 2;
        });
      }
    } catch (error) {
      ErrorHandler.showErrorSnackBar(
        context,
        error,
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _canContinue = _selectedFiles.length >= 2;
    });
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles.clear();
      _canContinue = false;
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

  int _calculateTotalSize() {
    return _selectedFiles.fold(0, (sum, file) => sum + file.size);
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
}

class _FileListItem extends StatelessWidget {
  final PdfFile file;
  final int index;
  final VoidCallback onDelete;

  const _FileListItem({
    Key? key,
    required this.file,
    required this.index,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
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
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _ReorderableFileCard extends StatelessWidget {
  final PdfFile file;
  final int index;
  final VoidCallback onDelete;

  const _ReorderableFileCard({
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientAlt1, AppColors.gradientAlt2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
                  const SizedBox(height: 4),
                  Text(
                    file.formattedSize,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.drag_handle,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _FileCountInfoCard extends StatelessWidget {
  final int fileCount;
  final int totalSize;

  const _FileCountInfoCard({
    Key? key,
    required this.fileCount,
    required this.totalSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _InfoItem(
              icon: Icons.file_copy,
              title: 'Files',
              value: fileCount.toString(),
              gradient: const [AppColors.gradientAlt1, AppColors.gradientAlt2],
            ),
            const SizedBox(width: 16),
            _InfoItem(
              icon: Icons.storage,
              title: 'Total Size',
              value: FileUtils.getFormattedFileSize(totalSize),
              gradient: const [Colors.orange, Colors.deepOrange],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<Color> gradient;

  const _InfoItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall,
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// lib/presentation/screens/compress/compress_screen.dart
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
import 'package:megapdf_flutter_client/presentation/widgets/compress/quality_selector.dart';
import 'package:megapdf_flutter_client/providers/compress_provider.dart';

class CompressScreen extends ConsumerStatefulWidget {
  const CompressScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends ConsumerState<CompressScreen> {
  PdfFile? _selectedFile;
  int _quality = AppConstants.defaultCompressionQuality;
  bool _isCompressing = false;
  int _currentStep = 0;
  bool _canContinue = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Hero(
          tag: 'compress-card',
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
            title: 'Select File',
            icon: Icons.file_copy,
            content: _buildFileSelectionStep(),
          ),
          ProgressStep(
            title: 'Configure',
            icon: Icons.settings,
            content: _buildCompressionSettingsStep(),
          ),
          ProgressStep(
            title: 'Compress',
            icon: Icons.compress,
            content: _buildCompressionProgressStep(),
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
                _canContinue = true;
              } else if (_currentStep == 2) {
                _compressPdf();
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
            'Select a PDF to compress',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a PDF file that you want to reduce in size. This tool will optimize the file while maintaining quality.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // File selection area
          if (_selectedFile == null) ...[
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
                    onTap: _selectFile,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/upload_file.json',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to select a PDF file',
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
                'Maximum file size: ${FileUtils.getFormattedFileSize(AppConstants.maxFileSize)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ] else ...[
            _SelectedFileCard(
              file: _selectedFile!,
              onRemove: _resetFile,
            ),
          ],

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCompressionSettingsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compression Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust the compression level to balance file size and quality.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Quality selector
          _ModernQualitySelector(
            quality: _quality,
            onChanged: (value) {
              setState(() {
                _quality = value;
              });
            },
          ),

          const Spacer(),

          // Compression info
          _buildCompressionInfoCard(),
        ],
      ),
    );
  }

  Widget _buildCompressionProgressStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isCompressing) ...[
            Lottie.asset(
              'assets/animations/compressing.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              'Compressing PDF...',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Please wait while we optimize your file',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 100,
            ),
            const SizedBox(height: 32),
            Text(
              'Ready to Compress',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Click the button below to start the compression process',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GradientButton(
              label: 'Start Compression',
              icon: Icons.compress,
              onPressed: _compressPdf,
              isLoading: _isCompressing,
              fullWidth: true,
              size: GradientButtonSize.large,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompressionInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Compression Quality Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _CompressionInfoRow(
              title: 'High Quality (80-100%)',
              description:
                  'Minimal compression, best for printing and archiving',
              icon: Icons.high_quality,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 16),
            _CompressionInfoRow(
              title: 'Medium Quality (40-70%)',
              description: 'Balanced compression, good for general usage',
              icon: Icons.photo,
              iconColor: Colors.amber,
            ),
            const SizedBox(height: 16),
            _CompressionInfoRow(
              title: 'Low Quality (10-30%)',
              description: 'Maximum compression, suitable for web sharing',
              icon: Icons.photo_size_select_small,
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _selectFile() async {
    try {
      final file = await FileUtils.pickPdfFile();
      if (file != null) {
        setState(() {
          _selectedFile = file;
          _canContinue = true;
        });
      }
    } catch (error) {
      ErrorHandler.showErrorSnackBar(
        context,
        error,
      );
    }
  }

  void _resetFile() {
    setState(() {
      _selectedFile = null;
      _canContinue = false;
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
}

class _SelectedFileCard extends StatelessWidget {
  final PdfFile file;
  final VoidCallback onRemove;

  const _SelectedFileCard({
    Key? key,
    required this.file,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red.shade700,
                    size: 32,
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
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onRemove,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernQualitySelector extends StatelessWidget {
  final int quality;
  final Function(int) onChanged;

  const _ModernQualitySelector({
    Key? key,
    required this.quality,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define quality levels
    final List<Map<String, dynamic>> qualityLevels = [
      {
        'value': 10,
        'label': 'Smallest',
        'icon': Icons.photo_size_select_small,
        'description': 'Maximum compression, lower quality',
        'color': Colors.red,
      },
      {
        'value': 30,
        'label': 'Small',
        'icon': Icons.photo_size_select_small,
        'description': 'High compression, acceptable quality',
        'color': Colors.orangeAccent,
      },
      {
        'value': 50,
        'label': 'Medium',
        'icon': Icons.photo,
        'description': 'Balanced compression and quality',
        'color': Colors.amber,
      },
      {
        'value': 70,
        'label': 'Good',
        'icon': Icons.photo,
        'description': 'Good quality, reasonable compression',
        'color': Colors.lightGreen,
      },
      {
        'value': 90,
        'label': 'Best',
        'icon': Icons.high_quality,
        'description': 'Highest quality, minimal compression',
        'color': Colors.green,
      },
    ];

    // Find the closest quality level
    final selectedIndex =
        qualityLevels.indexWhere((level) => level['value'] >= quality);
    final selectedLevel =
        selectedIndex >= 0 ? qualityLevels[selectedIndex] : qualityLevels.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current selected quality display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (selectedLevel['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (selectedLevel['color'] as Color).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selectedLevel['icon'] as IconData,
                  color: selectedLevel['color'] as Color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedLevel['label']} (${quality}%)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: selectedLevel['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedLevel['description'] as String,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Quality slider
        Text(
          'Adjust Quality',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: selectedLevel['color'] as Color,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: selectedLevel['color'] as Color,
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 24,
            ),
          ),
          child: Column(
            children: [
              Slider(
                min: 10,
                max: 100,
                divisions: 9,
                value: quality.toDouble(),
                onChanged: (value) => onChanged(value.round()),
              ),

              // Slider labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Smaller file',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Better quality',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Quality presets
        Text(
          'Quality Presets',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: qualityLevels.map((level) {
            final isSelected = level['value'] == quality;
            return _QualityPresetButton(
              label: level['label'] as String,
              value: level['value'] as int,
              isSelected: isSelected,
              color: level['color'] as Color,
              onTap: () => onChanged(level['value'] as int),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QualityPresetButton extends StatelessWidget {
  final String label;
  final int value;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _QualityPresetButton({
    Key? key,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompressionInfoRow extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const _CompressionInfoRow({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
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

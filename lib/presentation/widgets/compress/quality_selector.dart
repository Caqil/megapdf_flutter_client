import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';

class QualitySelector extends StatelessWidget {
  final int quality;
  final Function(int) onChanged;
  final int min;
  final int max;
  final int step;

  const QualitySelector({
    super.key,
    required this.quality,
    required this.onChanged,
    this.min = 10,
    this.max = 100,
    this.step = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lower quality',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Higher quality',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10.0,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 18.0,
            ),
          ),
          child: Slider(
            value: quality.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ step,
            label: _getQualityLabel(quality),
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QualityIndicator(
              label: 'Smaller file',
              icon: Icons.arrow_downward,
              color: Colors.green,
            ),
            Text(
              'Quality: ${quality.toString()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            _QualityIndicator(
              label: 'Better quality',
              icon: Icons.arrow_upward,
              color: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _CompressionExplanation(),
      ],
    );
  }

  String _getQualityLabel(int quality) {
    if (quality <= 30) {
      return 'Low Quality (${quality}%)';
    } else if (quality <= 60) {
      return 'Medium Quality (${quality}%)';
    } else if (quality <= 80) {
      return 'High Quality (${quality}%)';
    } else {
      return 'Best Quality (${quality}%)';
    }
  }
}

class _QualityIndicator extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _QualityIndicator({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CompressionExplanation extends StatelessWidget {
  const _CompressionExplanation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'How Compression Works',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _QualityExplanationRow(
              range: '10-30%',
              description:
                  'Maximum compression, good for archiving or email attachments. Image quality may be reduced.',
              tag: 'Low',
              tagColor: Colors.orange,
            ),
            const Divider(height: 16),
            _QualityExplanationRow(
              range: '40-60%',
              description:
                  'Balanced compression with acceptable quality for most purposes.',
              tag: 'Medium',
              tagColor: Colors.blue,
            ),
            const Divider(height: 16),
            _QualityExplanationRow(
              range: '70-90%',
              description:
                  'Minimal compression, preserves high quality, suitable for printing.',
              tag: 'High',
              tagColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityExplanationRow extends StatelessWidget {
  final String range;
  final String description;
  final String tag;
  final Color tagColor;

  const _QualityExplanationRow({
    required this.range,
    required this.description,
    required this.tag,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            range,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tagColor,
                  ),
                ),
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

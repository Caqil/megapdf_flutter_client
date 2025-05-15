// lib/presentation/widgets/convert/format_selector.dart

import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';

class FormatSelector extends StatelessWidget {
  final String selectedFormat;
  final List<String> formats;
  final Function(String) onFormatChanged;
  final bool horizontal;

  const FormatSelector({
    super.key,
    required this.selectedFormat,
    required this.formats,
    required this.onFormatChanged,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: formats.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final format = formats[index];
            return _FormatItem(
              format: format,
              isSelected: format == selectedFormat,
              onTap: () => onFormatChanged(format),
            );
          },
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: formats.map((format) {
        return _FormatItem(
          format: format,
          isSelected: format == selectedFormat,
          onTap: () => onFormatChanged(format),
        );
      }).toList(),
    );
  }
}

class _FormatItem extends StatelessWidget {
  final String format;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatItem({
    required this.format,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: isSelected ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFormatIcon(
                format,
                isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                format.toUpperCase(),
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatIcon(String format, Color color) {
    final IconData icon;

    switch (format.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        break;
      case 'docx':
      case 'doc':
        icon = Icons.description;
        break;
      case 'jpg':
      case 'jpeg':
        icon = Icons.image;
        break;
      case 'png':
        icon = Icons.image;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        break;
      case 'html':
        icon = Icons.code;
        break;
      default:
        icon = Icons.insert_drive_file;
        break;
    }

    return Icon(
      icon,
      size: 32,
      color: color,
    );
  }
}

// A more compact format selector for use in smaller spaces
class CompactFormatSelector extends StatelessWidget {
  final String selectedFormat;
  final List<String> formats;
  final Function(String) onFormatChanged;

  const CompactFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.formats,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFormat,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onFormatChanged(newValue);
            }
          },
          items: formats.map<DropdownMenuItem<String>>((String format) {
            return DropdownMenuItem<String>(
              value: format,
              child: Row(
                children: [
                  _buildFormatIcon(format),
                  const SizedBox(width: 8),
                  Text(format.toUpperCase()),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFormatIcon(String format) {
    final IconData icon;
    final Color color;

    switch (format.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'docx':
      case 'doc':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'jpg':
      case 'jpeg':
        icon = Icons.image;
        color = Colors.purple;
        break;
      case 'png':
        icon = Icons.image;
        color = Colors.indigo;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        color = Colors.grey;
        break;
      case 'html':
        icon = Icons.code;
        color = Colors.orange;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
        break;
    }

    return Icon(
      icon,
      size: 20,
      color: color,
    );
  }
}

// A format selector that shows feature comparison
class FormatComparisonSelector extends StatelessWidget {
  final String selectedFormat;
  final List<String> formats;
  final Function(String) onFormatChanged;

  const FormatComparisonSelector({
    super.key,
    required this.selectedFormat,
    required this.formats,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Output Format',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: formats.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            itemBuilder: (context, index) {
              final format = formats[index];
              return _FormatComparisonItem(
                format: format,
                isSelected: format == selectedFormat,
                onTap: () => onFormatChanged(format),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FormatComparisonItem extends StatelessWidget {
  final String format;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatComparisonItem({
    required this.format,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            _buildFormatIcon(format),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFormatName(format),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormatDescription(format),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatIcon(String format) {
    final IconData icon;
    final Color color;

    switch (format.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'docx':
      case 'doc':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'jpg':
      case 'jpeg':
        icon = Icons.image;
        color = Colors.purple;
        break;
      case 'png':
        icon = Icons.image;
        color = Colors.indigo;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        color = Colors.grey;
        break;
      case 'html':
        icon = Icons.code;
        color = Colors.orange;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: color,
        ),
      ),
    );
  }

  String _getFormatName(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return 'PDF Document';
      case 'docx':
        return 'Word Document';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'txt':
        return 'Plain Text';
      case 'html':
        return 'HTML Webpage';
      default:
        return format.toUpperCase();
    }
  }

  String _getFormatDescription(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return 'Portable Document Format, preserves layout and formatting';
      case 'docx':
        return 'Editable Microsoft Word document with text formatting';
      case 'jpg':
      case 'jpeg':
        return 'Compressed image format, suitable for photos';
      case 'png':
        return 'High-quality image format with transparency support';
      case 'txt':
        return 'Simple text file without formatting';
      case 'html':
        return 'Web page format viewable in browsers';
      default:
        return 'Document format';
    }
  }
}

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
        height: 110,
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
          width: 90,
          height: 100,
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
              const SizedBox(height: 4),
              Text(
                _getFormatName(format),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? theme.colorScheme.onPrimary.withOpacity(0.8)
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
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
      case 'jpg':
      case 'jpeg':
        icon = Icons.image;
        break;
      case 'png':
        icon = Icons.image;
        break;
      case 'tiff':
        icon = Icons.image;
        break;
      case 'docx':
      case 'doc':
        icon = Icons.description;
        break;
      case 'xlsx':
      case 'xls':
        icon = Icons.table_chart;
        break;
      case 'pptx':
      case 'ppt':
        icon = Icons.slideshow;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        break;
      case 'rtf':
        icon = Icons.text_format;
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

  String _getFormatName(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return 'Document';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'tiff':
        return 'TIFF Image';
      case 'docx':
        return 'Word Doc';
      case 'xlsx':
        return 'Excel Sheet';
      case 'pptx':
        return 'PowerPoint';
      case 'txt':
        return 'Plain Text';
      case 'rtf':
        return 'Rich Text';
      case 'html':
        return 'Web Page';
      default:
        return format.toUpperCase();
    }
  }
}

// An alternative format selector with more information
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
    final Color backgroundColor;
    final Color textColor;
    final IconData icon;

    switch (format.toLowerCase()) {
      case 'pdf':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.picture_as_pdf;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'tiff':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.image;
        break;
      case 'docx':
      case 'doc':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.description;
        break;
      case 'xlsx':
      case 'xls':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.table_chart;
        break;
      case 'pptx':
      case 'ppt':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.slideshow;
        break;
      case 'txt':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.text_snippet;
        break;
      case 'rtf':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        icon = Icons.text_format;
        break;
      case 'html':
        backgroundColor = Colors.cyan.shade100;
        textColor = Colors.cyan.shade800;
        icon = Icons.code;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.insert_drive_file;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: textColor,
        ),
      ),
    );
  }

  String _getFormatName(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return 'PDF Document';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'tiff':
        return 'TIFF Image';
      case 'docx':
        return 'Word Document';
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'pptx':
        return 'PowerPoint Presentation';
      case 'txt':
        return 'Plain Text';
      case 'rtf':
        return 'Rich Text Format';
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
      case 'jpg':
      case 'jpeg':
        return 'Compressed image format, suitable for photos';
      case 'png':
        return 'High-quality image format with transparency support';
      case 'tiff':
        return 'Professional image format often used in publishing';
      case 'docx':
        return 'Editable Microsoft Word document with text formatting';
      case 'xlsx':
        return 'Microsoft Excel spreadsheet with data and formulas';
      case 'pptx':
        return 'Microsoft PowerPoint presentation with slides';
      case 'txt':
        return 'Simple text file without formatting';
      case 'rtf':
        return 'Rich Text Format with basic text formatting';
      case 'html':
        return 'Web page format viewable in browsers';
      default:
        return 'Document format';
    }
  }
}

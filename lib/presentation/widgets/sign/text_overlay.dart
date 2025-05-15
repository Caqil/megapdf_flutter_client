// lib/presentation/widgets/sign/text_overlay.dart

import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';

class TextOverlay extends StatefulWidget {
  final Function(String,
      {Color? textColor, double? fontSize, String? fontFamily}) onSaved;
  final VoidCallback onCancel;
  final String? initialText;
  final Color? initialColor;
  final double? initialFontSize;
  final String? initialFontFamily;

  const TextOverlay({
    super.key,
    required this.onSaved,
    required this.onCancel,
    this.initialText,
    this.initialColor,
    this.initialFontSize,
    this.initialFontFamily,
  });

  @override
  State<TextOverlay> createState() => _TextOverlayState();
}

class _TextOverlayState extends State<TextOverlay> {
  final TextEditingController _textController = TextEditingController();
  Color _textColor = Colors.black;
  double _fontSize = 14.0;
  String _fontFamily = 'Roboto';

  // Available font families
  final List<String> _fontFamilies = [
    'Roboto',
    'Lato',
    'OpenSans',
    'Montserrat',
    'Raleway',
  ];

  // Available font sizes
  final List<double> _fontSizes = [
    8.0,
    10.0,
    12.0,
    14.0,
    16.0,
    18.0,
    20.0,
    24.0,
    28.0,
    32.0,
    36.0,
    48.0,
  ];

  // Available colors
  final List<Color> _colors = [
    Colors.black,
    Colors.grey.shade700,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText ?? '';
    _textColor = widget.initialColor ?? Colors.black;
    _fontSize = widget.initialFontSize ?? 14.0;
    _fontFamily = widget.initialFontFamily ?? 'Roboto';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveText() {
    if (_textController.text.trim().isEmpty) return;

    widget.onSaved(
      _textController.text,
      textColor: _textColor,
      fontSize: _fontSize,
      fontFamily: _fontFamily,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text input
                Text(
                  'Text',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Enter text here',
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  autofocus: true,
                ),
                const SizedBox(height: 24),

                // Font family selector
                Text(
                  'Font',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildFontFamilySelector(),
                const SizedBox(height: 24),

                // Font size selector
                Text(
                  'Size',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildFontSizeSelector(),
                const SizedBox(height: 24),

                // Color selector
                Text(
                  'Color',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildColorSelector(),
                const SizedBox(height: 24),

                // Preview
                Text(
                  'Preview',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _textController.text.isEmpty
                        ? 'Preview Text'
                        : _textController.text,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: _fontSize,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppButton(
                label: 'Cancel',
                icon: Icons.close,
                onPressed: widget.onCancel,
                type: AppButtonType.outline,
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Add Text',
                icon: Icons.check,
                onPressed:
                    _textController.text.trim().isEmpty ? null : _saveText,
                type: AppButtonType.primary,
                isDisabled: _textController.text.trim().isEmpty,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFontFamilySelector() {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: _fontFamilies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final fontFamily = _fontFamilies[index];
          final isSelected = fontFamily == _fontFamily;

          return GestureDetector(
            onTap: () {
              setState(() {
                _fontFamily = fontFamily;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                fontFamily,
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFontSizeSelector() {
    final theme = Theme.of(context);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                final index = _fontSizes.indexOf(_fontSize);
                if (index > 0) {
                  _fontSize = _fontSizes[index - 1];
                }
              });
            },
          ),
          Expanded(
            child: Slider(
              value: _fontSize,
              min: _fontSizes.first,
              max: _fontSizes.last,
              divisions: _fontSizes.length - 1,
              label: '${_fontSize.toInt()}',
              onChanged: (value) {
                setState(() {
                  // Find the closest font size in our list
                  _fontSize = _fontSizes.reduce((a, b) {
                    return (a - value).abs() < (b - value).abs() ? a : b;
                  });
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                final index = _fontSizes.indexOf(_fontSize);
                if (index < _fontSizes.length - 1) {
                  _fontSize = _fontSizes[index + 1];
                }
              });
            },
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '${_fontSize.toInt()}',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: _colors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final color = _colors[index];
          final isSelected = color == _textColor;

          return GestureDetector(
            onTap: () {
              setState(() {
                _textColor = color;
              });
            },
            child: Container(
              width: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.5),
                  width: isSelected ? 3 : 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

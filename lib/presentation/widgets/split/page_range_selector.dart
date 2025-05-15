// lib/presentation/widgets/split/page_range_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/utils/format_utils.dart';

class PageRangeSelector extends StatefulWidget {
  final TextEditingController controller;
  final int pageCount;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const PageRangeSelector({
    super.key,
    required this.controller,
    required this.pageCount,
    this.hintText,
    this.onChanged,
  });

  @override
  State<PageRangeSelector> createState() => _PageRangeSelectorState();
}

class _PageRangeSelectorState extends State<PageRangeSelector> {
  List<int> _selectedPages = [];
  bool _isValid = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Try to parse initial value if present
    if (widget.controller.text.isNotEmpty) {
      _validateInput(widget.controller.text);
    }

    // Listen for changes
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    _validateInput(widget.controller.text);
    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  void _validateInput(String value) {
    if (value.isEmpty) {
      setState(() {
        _selectedPages = [];
        _isValid = true;
        _errorMessage = '';
      });
      return;
    }

    try {
      final pages = FormatUtils.parsePageRanges(value, widget.pageCount);
      setState(() {
        _selectedPages = pages;
        _isValid = true;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _selectedPages = [];
        _isValid = false;
        _errorMessage = 'Invalid range format. Use format like: 1-3,5,7-9';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'e.g., 1-3,5,7-9',
            prefixIcon: const Icon(Icons.format_list_numbered),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                    },
                  )
                : null,
            errorText: _isValid ? null : _errorMessage,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,-]')),
          ],
        ),
        if (_selectedPages.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Selected pages: ${_selectedPages.length}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _PagePreview(
            selectedPages: _selectedPages,
            totalPages: widget.pageCount,
          ),
        ],
        const SizedBox(height: 16),
        _QuickSelectionButtons(
          pageCount: widget.pageCount,
          onSelect: (value) {
            widget.controller.text = value;
          },
        ),
      ],
    );
  }
}

class _PagePreview extends StatelessWidget {
  final List<int> selectedPages;
  final int totalPages;
  final int maxDisplayed;

  const _PagePreview({
    required this.selectedPages,
    required this.totalPages,
    this.maxDisplayed = 50,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Limit the number of pages shown in preview
    final displayPages = totalPages <= maxDisplayed ? totalPages : maxDisplayed;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayPages,
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          final isSelected = selectedPages.contains(pageNumber);

          return Container(
            width: 30,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                pageNumber.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickSelectionButtons extends StatelessWidget {
  final int pageCount;
  final ValueChanged<String> onSelect;

  const _QuickSelectionButtons({
    required this.pageCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildQuickButton(
          context,
          label: 'All Pages',
          value: '1-$pageCount',
          icon: Icons.select_all,
        ),
        _buildQuickButton(
          context,
          label: 'First Page',
          value: '1',
          icon: Icons.first_page,
        ),
        _buildQuickButton(
          context,
          label: 'Last Page',
          value: pageCount.toString(),
          icon: Icons.last_page,
        ),
        _buildQuickButton(
          context,
          label: 'Even Pages',
          value: _getEvenPagesRange(),
          icon: Icons.filter_2,
        ),
        _buildQuickButton(
          context,
          label: 'Odd Pages',
          value: _getOddPagesRange(),
          icon: Icons.filter_1,
        ),
      ],
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: () => onSelect(value),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
    );
  }

  String _getEvenPagesRange() {
    final List<int> evenPages = [];
    for (int i = 2; i <= pageCount; i += 2) {
      evenPages.add(i);
    }
    return evenPages.join(',');
  }

  String _getOddPagesRange() {
    final List<int> oddPages = [];
    for (int i = 1; i <= pageCount; i += 2) {
      oddPages.add(i);
    }
    return oddPages.join(',');
  }
}

// A simpler version that doesn't include the preview
class SimplePageRangeInput extends StatelessWidget {
  final TextEditingController controller;
  final int pageCount;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const SimplePageRangeInput({
    super.key,
    required this.controller,
    required this.pageCount,
    this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText ?? 'e.g., 1-3,5,7-9',
        prefixIcon: const Icon(Icons.format_list_numbered),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        helperText: 'Total pages: $pageCount',
      ),
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,-]')),
      ],
      onChanged: onChanged,
    );
  }
}

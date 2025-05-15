// lib/presentation/widgets/common/page_selector.dart

import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';

class PageSelector extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageSelected;
  final bool showThumbnails;
  final List<Widget>? thumbnails;
  final double height;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;

  const PageSelector({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.showThumbnails = false,
    this.thumbnails,
    this.height = 60,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
  });

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  late ScrollController _scrollController;
  late TextEditingController _pageInputController;
  bool _isEditingPage = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageInputController = TextEditingController(
      text: widget.currentPage.toString(),
    );

    // Scroll to the current page initially after the layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPage();
    });
  }

  @override
  void didUpdateWidget(PageSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text controller when current page changes
    if (oldWidget.currentPage != widget.currentPage && !_isEditingPage) {
      _pageInputController.text = widget.currentPage.toString();
      _scrollToCurrentPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageInputController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPage() {
    if (!_scrollController.hasClients) return;

    // Calculate the position to scroll to
    final itemWidth = 60.0; // Approximate width of each page item
    final totalWidth = _scrollController.position.viewportDimension;
    final targetPosition = (widget.currentPage - 1) * itemWidth;

    // Scroll to center the current page
    _scrollController.animateTo(
      targetPosition - (totalWidth / 2) + (itemWidth / 2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handlePageSubmitted(String value) {
    final page = int.tryParse(value);
    if (page != null && page > 0 && page <= widget.totalPages) {
      widget.onPageSelected(page);
    } else {
      // Reset to current page if invalid input
      _pageInputController.text = widget.currentPage.toString();
    }
    setState(() {
      _isEditingPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;
    final textColor = widget.textColor ?? theme.colorScheme.onSurface;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Previous page button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.currentPage > 1
                ? () => widget.onPageSelected(widget.currentPage - 1)
                : null,
          ),

          // Page input field
          SizedBox(
            width: 60,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingPage = true;
                });
                _pageInputController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _pageInputController.text.length,
                );
              },
              child: _isEditingPage
                  ? TextField(
                      controller: _pageInputController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                      onSubmitted: _handlePageSubmitted,
                      onEditingComplete: () {
                        _handlePageSubmitted(_pageInputController.text);
                      },
                    )
                  : Text(
                      '${widget.currentPage} / ${widget.totalPages}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          // Next page button
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: widget.currentPage < widget.totalPages
                ? () => widget.onPageSelected(widget.currentPage + 1)
                : null,
          ),

          // Page navigator (scrollable)
          if (widget.totalPages > 1) ...[
            Expanded(
              child: widget.showThumbnails && widget.thumbnails != null
                  ? _buildThumbnailSelector()
                  : _buildPageNumberSelector(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageNumberSelector() {
    final theme = Theme.of(context);
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: widget.totalPages,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        final isSelected = pageNumber == widget.currentPage;

        return GestureDetector(
          onTap: () => widget.onPageSelected(pageNumber),
          child: Container(
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? selectedColor
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              pageNumber.toString(),
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailSelector() {
    final theme = Theme.of(context);
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: widget.totalPages,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        final isSelected = pageNumber == widget.currentPage;

        return GestureDetector(
          onTap: () => widget.onPageSelected(pageNumber),
          child: Container(
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? selectedColor
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: index < (widget.thumbnails?.length ?? 0)
                ? widget.thumbnails![index]
                : Container(
                    color: theme.colorScheme.surface,
                    alignment: Alignment.center,
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// A simpler version of the page selector that just shows buttons
class SimplePageSelector extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageSelected;
  final Color? backgroundColor;
  final Color? textColor;

  const SimplePageSelector({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = this.backgroundColor ?? theme.colorScheme.surface;
    final textColor = this.textColor ?? theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                currentPage > 1 ? () => onPageSelected(currentPage - 1) : null,
          ),
          Text(
            '$currentPage / $totalPages',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: currentPage < totalPages
                ? () => onPageSelected(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

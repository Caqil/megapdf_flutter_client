import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/core/error/error_handler.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';
import 'package:megapdf_flutter_client/core/widgets/app_loading.dart';
import 'package:path_provider/path_provider.dart';

class FileViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String? localFilePath; // Add this parameter

  const FileViewerScreen({
    super.key,
    required this.fileUrl,
    required this.fileName,
    this.localFilePath, // Pass local path if available
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _filePath;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();

    // Use local file path if provided
    if (widget.localFilePath != null &&
        File(widget.localFilePath!).existsSync()) {
      setState(() {
        _filePath = widget.localFilePath;
        _isLoading = false;
      });
    } else {
      _downloadFile();
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _downloadFile() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      // Create temp file to store the pdf
      final tempDir = await getTemporaryDirectory();
      final previewDirPath = '${tempDir.path}/previews';
      final tempFilePath = '$previewDirPath/${widget.fileName}';

      // Ensure directory exists
      final dir = Directory(previewDirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Check if file already exists in temp directory
      final tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        setState(() {
          _filePath = tempFilePath;
          _isLoading = false;
        });
        return;
      }

      // Log the URL to help debug
      debugPrint('FileViewer downloading from URL: ${widget.fileUrl}');

      // Download the file
      final file = await FileUtils.saveFileFromUrl(
        widget.fileUrl,
        widget.fileName,
        directoryPath: previewDirPath,
      );

      if (mounted) {
        setState(() {
          _filePath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e is AppError
              ? e.message
              : 'Failed to load file: ${e.toString()}';
        });

        // Log the error for debugging
        debugPrint('Error in FileViewer: ${e.toString()}');
      }
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _totalPages = details.document.pages.count;
    });
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() {
      _currentPage = details.newPageNumber;
    });
  }

  Future<void> _saveFile() async {
    if (_filePath == null) return;

    try {
      final file = File(_filePath!);
      final savedPath = await FileUtils.saveFileToDownloads(
        file,
        widget.fileName,
      );

      if (mounted && savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to downloads: ${widget.fileName}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          e,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          if (!_isLoading && !_hasError && _filePath != null)
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: 'Save to Downloads',
              onPressed: _saveFile,
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: AppLoading(
          message: 'Loading document...',
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load document',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Try Again',
                icon: Icons.refresh,
                onPressed: _downloadFile,
                type: AppButtonType.primary,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Go Back',
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
                type: AppButtonType.outline,
              ),
            ],
          ),
        ),
      );
    }

    if (_filePath == null) {
      return const Center(
        child: Text('No file to display'),
      );
    }

    // Check file extension
    final fileExtension =
        FileUtils.getFileExtension(widget.fileName).toLowerCase();

    // Handle PDF files
    if (fileExtension == 'pdf') {
      return SfPdfViewer.file(
        File(_filePath!),
        controller: _pdfViewerController,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        pageSpacing: 4,
        onZoomLevelChanged: (details) {
          setState(() {
            _zoomLevel = details.newZoomLevel;
          });
        },
      );
    }

    // Handle image files
    else if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
      return Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(_filePath!),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // For other file types, show unsupported message
    else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.file_present,
                color: AppColors.warning,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Unsupported File Type',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This file type (.$fileExtension) cannot be previewed in the app.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Save to Downloads',
                icon: Icons.save_alt,
                onPressed: _saveFile,
                type: AppButtonType.primary,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Go Back',
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
                type: AppButtonType.outline,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget? _buildBottomBar() {
    if (_isLoading || _hasError || _filePath == null) {
      return null;
    }

    final fileExtension =
        FileUtils.getFileExtension(widget.fileName).toLowerCase();

    // Only show navigation bar for PDF files
    if (fileExtension == 'pdf' && _totalPages > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Page navigation
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentPage > 1
                      ? () => _pdfViewerController.previousPage()
                      : null,
                  tooltip: 'Previous Page',
                ),
                Text(
                  '$_currentPage / $_totalPages',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _currentPage < _totalPages
                      ? () => _pdfViewerController.nextPage()
                      : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),

            // Zoom controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: _zoomLevel > 1.0
                      ? () => _pdfViewerController.zoomLevel = _zoomLevel - 0.25
                      : null,
                  tooltip: 'Zoom Out',
                ),
                Text(
                  '${(_zoomLevel * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: _zoomLevel < 3.0
                      ? () => _pdfViewerController.zoomLevel = _zoomLevel + 0.25
                      : null,
                  tooltip: 'Zoom In',
                ),
              ],
            ),
          ],
        ),
      );
    }

    return null;
  }
}

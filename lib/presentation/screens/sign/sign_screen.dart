// lib/presentation/screens/sign/sign_screen.dart

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
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
import 'package:megapdf_flutter_client/presentation/widgets/sign/signature_pad.dart';
import 'package:megapdf_flutter_client/presentation/widgets/sign/text_overlay.dart';
import 'package:megapdf_flutter_client/providers/sign_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SignScreen extends ConsumerStatefulWidget {
  const SignScreen({super.key});

  @override
  ConsumerState<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends ConsumerState<SignScreen> {
  PdfFile? _selectedFile;
  bool _isSigning = false;
  bool _isLoadingPdf = false;

  // PDF viewer controller
  final PdfViewerController _pdfViewerController = PdfViewerController();

  // Current page
  int _currentPage = 1;
  int _totalPages = 0;

  // Signature elements
  List<SignatureElement> _signatures = [];
  List<TextElement> _textElements = [];

  // Create mode
  bool _isAddingSignature = false;
  bool _isAddingText = false;

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _selectFile(PdfFile file) {
    setState(() {
      _selectedFile = file;
      _isLoadingPdf = true;
      _signatures = [];
      _textElements = [];
      _currentPage = 1;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _isLoadingPdf = false;
      _signatures = [];
      _textElements = [];
      _currentPage = 1;
      _totalPages = 0;
      _isAddingSignature = false;
      _isAddingText = false;
    });
  }

  void _addSignature(String signatureData) {
    final newSignature = SignatureElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      page: _currentPage,
      position: const Offset(100, 100),
      size: const Size(200, 100),
      data: signatureData,
      rotation: 0,
      scale: 1.0,
    );

    setState(() {
      _signatures.add(newSignature);
      _isAddingSignature = false;
    });
  }

  void _addTextElement(
    String text, {
    Color? textColor,
    double? fontSize,
    String? fontFamily,
  }) {
    final newText = TextElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      page: _currentPage,
      position: const Offset(100, 100),
      text: text,
      textColor: textColor ?? Colors.black,
      fontSize: fontSize ?? 14,
      fontFamily: fontFamily ?? 'Roboto',
      rotation: 0,
    );

    setState(() {
      _textElements.add(newText);
      _isAddingText = false;
    });
  }

  void _removeElement(String id) {
    setState(() {
      _signatures.removeWhere((element) => element.id == id);
      _textElements.removeWhere((element) => element.id == id);
    });
  }

  void _onPdfDocumentLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _totalPages = details.document.pages.count;
      _isLoadingPdf = false;
    });
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() {
      _currentPage = details.newPageNumber;
    });
  }

  Future<void> _signPdf() async {
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

    if (_signatures.isEmpty && _textElements.isEmpty) {
      ErrorHandler.showErrorSnackBar(
        context,
        AppError(
          message: 'Please add at least one signature or text element',
          type: AppErrorType.validation,
        ),
      );
      return;
    }

    setState(() {
      _isSigning = true;
    });

    try {
      final result = await ref.read(signProvider.notifier).signPdf(
            file: _selectedFile!,
            signatures: _signatures,
            textElements: _textElements,
          );

      if (!mounted) return;

      // Navigate to result screen
      context.pushReplacement(
        RouteNames.resultPath,
        extra: {
          'operation': AppConstants.operationSign,
          'fileUrl': result.fileUrl,
          'fileName': result.filename,
          'originalName': result.originalName,
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSigning = false;
      });

      ErrorHandler.showErrorDialog(
        context,
        error,
        onRetry: _signPdf,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign PDF'),
        actions: [
          if (_selectedFile != null && !_isLoadingPdf)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _signPdf,
              tooltip: 'Apply Signatures',
            ),
        ],
      ),
      body: AppLoadingOverlay(
        isLoading: _isSigning,
        message: 'Applying signatures...',
        child: _isAddingSignature
            ? _buildSignaturePad()
            : _isAddingText
                ? _buildTextInput()
                : _buildMainContent(theme),
      ),
      bottomNavigationBar: _selectedFile != null && !_isLoadingPdf
          ? _buildBottomToolbar()
          : null,
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    if (_selectedFile == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header and info
            Text(
              'Sign PDF Documents',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add signatures and text to your PDF documents.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // File selection area
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
          ],
        ),
      );
    }

    if (_isLoadingPdf) {
      return const Center(
        child: AppLoading(message: 'Loading PDF...'),
      );
    }

    return Stack(
      children: [
        // PDF Viewer
        SfPdfViewer.file(
          _selectedFile!.file!,
          controller: _pdfViewerController,
          onDocumentLoaded: _onPdfDocumentLoaded,
          onPageChanged: _onPageChanged,
          enableTextSelection: false,
        ),

        // Overlay for signatures and text elements
        ..._buildSignatureOverlays(),
        ..._buildTextOverlays(),
      ],
    );
  }

  List<Widget> _buildSignatureOverlays() {
    return _signatures
        .where((sig) => sig.page == _currentPage)
        .map((sig) => Positioned(
              left: sig.position.dx,
              top: sig.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final index = _signatures.indexOf(sig);
                    _signatures[index] = sig.copyWith(
                      position: Offset(
                        sig.position.dx + details.delta.dx,
                        sig.position.dy + details.delta.dy,
                      ),
                    );
                  });
                },
                child: Stack(
                  children: [
                    Transform.rotate(
                      angle: sig.rotation * 3.14159 / 180,
                      child: Image.memory(
                        base64Decode(sig.data),
                        width: sig.size.width,
                        height: sig.size.height,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeElement(sig.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _buildTextOverlays() {
    return _textElements
        .where((text) => text.page == _currentPage)
        .map((textEl) => Positioned(
              left: textEl.position.dx,
              top: textEl.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final index = _textElements.indexOf(textEl);
                    _textElements[index] = textEl.copyWith(
                      position: Offset(
                        textEl.position.dx + details.delta.dx,
                        textEl.position.dy + details.delta.dy,
                      ),
                    );
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1,
                        ),
                        color: Colors.white.withOpacity(0.7),
                      ),
                      child: Transform.rotate(
                        angle: textEl.rotation * 3.14159 / 180,
                        child: Text(
                          textEl.text,
                          style: TextStyle(
                            color: textEl.textColor,
                            fontSize: textEl.fontSize,
                            fontFamily: textEl.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeElement(textEl.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  Widget _buildBottomToolbar() {
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

          // Signature tools
          Row(
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.draw, size: 18),
                label: const Text('Add Signature'),
                onPressed: () {
                  setState(() {
                    _isAddingSignature = true;
                  });
                },
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.text_fields, size: 18),
                label: const Text('Add Text'),
                onPressed: () {
                  setState(() {
                    _isAddingText = true;
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Column(
      children: [
        AppBar(
          title: const Text('Draw Signature'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isAddingSignature = false;
              });
            },
          ),
        ),
        Expanded(
          child: SignaturePad(
            onSaved: _addSignature,
            onCancel: () {
              setState(() {
                _isAddingSignature = false;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Column(
      children: [
        AppBar(
          title: const Text('Add Text'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isAddingText = false;
              });
            },
          ),
        ),
        Expanded(
          child: TextOverlay(
            onSaved: _addTextElement,
            onCancel: () {
              setState(() {
                _isAddingText = false;
              });
            },
          ),
        ),
      ],
    );
  }
}

class SignatureElement {
  final String id;
  final int page;
  final Offset position;
  final Size size;
  final String data; // Base64 encoded image data
  final double rotation;
  final double scale;

  SignatureElement({
    required this.id,
    required this.page,
    required this.position,
    required this.size,
    required this.data,
    required this.rotation,
    required this.scale,
  });

  SignatureElement copyWith({
    String? id,
    int? page,
    Offset? position,
    Size? size,
    String? data,
    double? rotation,
    double? scale,
  }) {
    return SignatureElement(
      id: id ?? this.id,
      page: page ?? this.page,
      position: position ?? this.position,
      size: size ?? this.size,
      data: data ?? this.data,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page': page,
      'position': {'x': position.dx, 'y': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'data': data,
      'rotation': rotation,
      'scale': scale,
    };
  }
}

class TextElement {
  final String id;
  final int page;
  final Offset position;
  final String text;
  final Color textColor;
  final double fontSize;
  final String fontFamily;
  final double rotation;

  TextElement({
    required this.id,
    required this.page,
    required this.position,
    required this.text,
    required this.textColor,
    required this.fontSize,
    required this.fontFamily,
    required this.rotation,
  });

  TextElement copyWith({
    String? id,
    int? page,
    Offset? position,
    String? text,
    Color? textColor,
    double? fontSize,
    String? fontFamily,
    double? rotation,
  }) {
    return TextElement(
      id: id ?? this.id,
      page: page ?? this.page,
      position: position ?? this.position,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page': page,
      'position': {'x': position.dx, 'y': position.dy},
      'text': text,
      'textColor': textColor.value.toRadixString(16),
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'rotation': rotation,
    };
  }
}

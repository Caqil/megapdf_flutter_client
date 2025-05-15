// lib/presentation/widgets/sign/signature_pad.dart

import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';

class SignaturePad extends StatefulWidget {
  final Function(String) onSaved;
  final VoidCallback onCancel;
  final Color penColor;
  final double strokeWidth;
  final Color backgroundColor;

  const SignaturePad({
    super.key,
    required this.onSaved,
    required this.onCancel,
    this.penColor = Colors.black,
    this.strokeWidth = 3.0,
    this.backgroundColor = Colors.white,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  bool _isSigning = false;
  bool _hasSignature = false;

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isSigning = true;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isSigning = false;
      _checkIfHasSignature();
    });
  }

  Future<void> _checkIfHasSignature() async {
    try {
      final signatureData = await _signaturePadKey.currentState?.toImage();
      if (signatureData != null) {
        final bytes =
            await signatureData.toByteData(format: ui.ImageByteFormat.png);
        if (bytes != null && bytes.lengthInBytes > 1000) {
          // If image data is larger than 1KB, assume there's a signature
          // This threshold helps avoid detecting tiny dots or line segments
          setState(() {
            _hasSignature = true;
          });
          return;
        }
      }

      setState(() {
        _hasSignature = false;
      });
    } catch (e) {
      setState(() {
        _hasSignature = false;
      });
    }
  }

  Future<void> _saveSignature() async {
    try {
      // Get the signature as an image
      final signatureData = await _signaturePadKey.currentState?.toImage();
      if (signatureData == null) return;

      // Convert image to bytes
      final bytes =
          await signatureData.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;

      // Convert bytes to base64 string
      final base64 = base64Encode(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

      // Send signature data back
      widget.onSaved(base64);
    } catch (e) {
      debugPrint('Error saving signature: $e');
    }
  }

  void _clearSignature() {
    _signaturePadKey.currentState?.clear();
    setState(() {
      _hasSignature = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Signature pad
                  SfSignaturePad(
                    key: _signaturePadKey,
                    backgroundColor: widget.backgroundColor,
                    strokeColor: widget.penColor,
                    minimumStrokeWidth: widget.strokeWidth,
                    maximumStrokeWidth: widget.strokeWidth * 1.5,
                    onDrawStart: _handlePanStart,
                    onDrawEnd: _handlePanEnd,
                  ),

                  // Guide line
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 40,
                    child: Container(
                      height: 1,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),

                  // "Sign here" placeholder text
                  if (!_isSigning && !_hasSignature)
                    Center(
                      child: Text(
                        'Sign here',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                          fontSize: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Button bar
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
                label: 'Clear',
                icon: Icons.delete_outline,
                onPressed: _clearSignature,
                type: AppButtonType.outline,
                isDisabled: !_hasSignature,
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Cancel',
                icon: Icons.close,
                onPressed: widget.onCancel,
                type: AppButtonType.text,
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Save',
                icon: Icons.check,
                onPressed: _hasSignature ? _saveSignature : null,
                type: AppButtonType.primary,
                isDisabled: !_hasSignature,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// A simpler widget that just displays a signature
class SignatureDisplay extends StatelessWidget {
  final String signatureData; // Base64 encoded image
  final double width;
  final double height;
  final BoxFit fit;
  final Color backgroundColor;

  const SignatureDisplay({
    super.key,
    required this.signatureData,
    this.width = 200,
    this.height = 100,
    this.fit = BoxFit.contain,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          base64Decode(signatureData),
          fit: fit,
        ),
      ),
    );
  }
}

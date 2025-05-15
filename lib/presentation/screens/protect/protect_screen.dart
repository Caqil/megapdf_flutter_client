// lib/presentation/screens/protect/protect_screen.dart

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
import 'package:megapdf_flutter_client/providers/protect_provider.dart';

class ProtectScreen extends ConsumerStatefulWidget {
  const ProtectScreen({super.key});

  @override
  ConsumerState<ProtectScreen> createState() => _ProtectScreenState();
}

class _ProtectScreenState extends ConsumerState<ProtectScreen> {
  PdfFile? _selectedFile;
  bool _isProtecting = false;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Permission options
  bool _restrictPrinting = true;
  bool _restrictEditing = true;
  bool _restrictCopying = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _selectFile(PdfFile file) {
    setState(() {
      _selectedFile = file;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _passwordController.clear();
      _confirmPasswordController.clear();
      _restrictPrinting = true;
      _restrictEditing = true;
      _restrictCopying = true;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 4) {
      return 'Password must be at least 4 characters long';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _protectPdf() async {
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

    // Validate password fields
    final passwordError = _validatePassword(_passwordController.text);
    if (passwordError != null) {
      ErrorHandler.showErrorSnackBar(
        context,
        AppError(
          message: passwordError,
          type: AppErrorType.validation,
        ),
      );
      return;
    }

    final confirmPasswordError =
        _validateConfirmPassword(_confirmPasswordController.text);
    if (confirmPasswordError != null) {
      ErrorHandler.showErrorSnackBar(
        context,
        AppError(
          message: confirmPasswordError,
          type: AppErrorType.validation,
        ),
      );
      return;
    }

    setState(() {
      _isProtecting = true;
    });

    try {
      final result = await ref.read(protectProvider.notifier).protectPdf(
            file: _selectedFile!,
            password: _passwordController.text,
            restrictPrinting: _restrictPrinting,
            restrictEditing: _restrictEditing,
            restrictCopying: _restrictCopying,
          );

      if (!mounted) return;

      // Navigate to result screen
      context.pushReplacement(
        RouteNames.resultPath,
        extra: {
          'operation': AppConstants.operationProtect,
          'fileUrl': result.fileUrl,
          'fileName': result.filename,
          'originalName': result.originalName,
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isProtecting = false;
      });

      ErrorHandler.showErrorDialog(
        context,
        error,
        onRetry: _protectPdf,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protect PDF'),
      ),
      body: AppLoadingOverlay(
        isLoading: _isProtecting,
        message: 'Protecting PDF...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and info
              Text(
                'Add password protection',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Secure your PDF with password protection and permission restrictions.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // File selection area
              if (_selectedFile == null) ...[
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
              ] else ...[
                _SelectedFileCard(
                  file: _selectedFile!,
                  onRemove: _resetForm,
                ),
                const SizedBox(height: 24),

                // Password section
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Password',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a strong password to encrypt your PDF file.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter a password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),

                        // Confirm password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Confirm your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: _toggleConfirmPasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: _validateConfirmPassword,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Permissions section
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Permissions',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Control what users can do with your PDF.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),

                        // Permission checkboxes
                        CheckboxListTile(
                          title: const Text('Restrict Printing'),
                          subtitle: const Text(
                              'Prevent users from printing the document'),
                          value: _restrictPrinting,
                          onChanged: (value) {
                            setState(() {
                              _restrictPrinting = value ?? true;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: const Text('Restrict Editing'),
                          subtitle: const Text(
                              'Prevent users from modifying the document'),
                          value: _restrictEditing,
                          onChanged: (value) {
                            setState(() {
                              _restrictEditing = value ?? true;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: const Text('Restrict Copying'),
                          subtitle:
                              const Text('Prevent users from copying content'),
                          value: _restrictCopying,
                          onChanged: (value) {
                            setState(() {
                              _restrictCopying = value ?? true;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Protect button
                AppButton(
                  label: 'Protect PDF',
                  onPressed: _protectPdf,
                  isLoading: _isProtecting,
                  isDisabled: _isProtecting,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  icon: Icons.lock_outline,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedFileCard extends StatelessWidget {
  final PdfFile file;
  final VoidCallback onRemove;

  const _SelectedFileCard({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, size: 32, color: Colors.red),
              const SizedBox(width: 12),
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
                    Text(
                      file.formattedSize,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onRemove,
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

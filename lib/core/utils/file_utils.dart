// lib/core/utils/file_utils.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class FileUtils {
  // Pick a single PDF file
  static Future<PdfFile?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.pdfExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final platformFile = result.files.first;

      // Handle web platform separately
      if (kIsWeb) {
        return PdfFile(
          name: platformFile.name,
          path: '', // Web doesn't have file paths
          size: platformFile.size,
          lastModified: DateTime.now(),
          extension: 'pdf',
          mimeType: 'application/pdf',
        );
      }

      // For mobile/desktop platforms
      final file = File(platformFile.path!);
      return PdfFile.fromFile(file);
    } catch (e) {
      throw AppError(
        message: 'Error picking PDF file: ${e.toString()}',
        type: AppErrorType.fileAccess,
      );
    }
  }

  // Pick multiple PDF files
  static Future<List<PdfFile>> pickMultiplePdfFiles({int maxFiles = 10}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.pdfExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      // Limit the number of files
      final files = result.files.take(maxFiles).toList();

      // Handle web platform separately
      if (kIsWeb) {
        return files
            .map((platformFile) => PdfFile(
                  name: platformFile.name,
                  path: '', // Web doesn't have file paths
                  size: platformFile.size,
                  lastModified: DateTime.now(),
                  extension: 'pdf',
                  mimeType: 'application/pdf',
                ))
            .toList();
      }

      // For mobile/desktop platforms
      return files
          .map((platformFile) => PdfFile.fromFile(File(platformFile.path!)))
          .toList();
    } catch (e) {
      throw AppError(
        message: 'Error picking PDF files: ${e.toString()}',
        type: AppErrorType.fileAccess,
      );
    }
  }

  // Pick file by type (documents, images, etc.)
  static Future<PdfFile?> pickFile({
    required List<String> allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        dialogTitle: dialogTitle,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final platformFile = result.files.first;

      // Handle web platform separately
      if (kIsWeb) {
        final extension = path
            .extension(platformFile.name)
            .toLowerCase()
            .replaceFirst('.', '');
        return PdfFile(
          name: platformFile.name,
          path: '', // Web doesn't have file paths
          size: platformFile.size,
          lastModified: DateTime.now(),
          extension: extension,
          mimeType: _getMimeType(extension),
        );
      }

      // For mobile/desktop platforms
      final file = File(platformFile.path!);
      return PdfFile.fromFile(file);
    } catch (e) {
      throw AppError(
        message: 'Error picking file: ${e.toString()}',
        type: AppErrorType.fileAccess,
      );
    }
  }

  // Get mime type from extension
  static String _getMimeType(String extension) {
    return lookupMimeType('file.$extension') ?? 'application/octet-stream';
  }

  // Save file from URL
  static Future<File> saveFileFromUrl(
    String url,
    String filename, {
    String? directoryPath,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Create a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath = directoryPath ?? tempDir.path;
      final filePath = '$tempPath/${const Uuid().v4()}_$filename';
      final file = File(filePath);

      // Download the file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw AppError(
          message:
              'Failed to download file. Server returned ${response.statusCode}',
          type: AppErrorType.network,
        );
      }

      // Write the file
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Error saving file from URL: ${e.toString()}',
        type: AppErrorType.fileAccess,
      );
    }
  }

  // Save file to downloads directory (mobile)
  static Future<String?> saveFileToDownloads(
    File file,
    String filename,
  ) async {
    try {
      final params = SaveFileDialogParams(
        sourceFilePath: file.path,
        fileName: filename,
      );

      return await FlutterFileDialog.saveFile(params: params);
    } catch (e) {
      throw AppError(
        message: 'Error saving file to downloads: ${e.toString()}',
        type: AppErrorType.fileAccess,
      );
    }
  }

  // Open file with default app
  static Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        throw AppError(
          message: 'Failed to open file: ${result.message}',
          type: AppErrorType.fileAccess,
        );
      }
    } catch (e) {
      throw AppError(
        message: 'Error opening file: ${e.toString()}',
        type: AppErrorType.fileAccess,
      );
    }
  }

  // Get file size in human-readable format
  static String getFormattedFileSize(int sizeInBytes) {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (sizeInBytes >= gb) {
      return '${(sizeInBytes / gb).toStringAsFixed(2)} GB';
    } else if (sizeInBytes >= mb) {
      return '${(sizeInBytes / mb).toStringAsFixed(2)} MB';
    } else if (sizeInBytes >= kb) {
      return '${(sizeInBytes / kb).toStringAsFixed(2)} KB';
    } else {
      return '$sizeInBytes B';
    }
  }

  // Check if file size is within limits
  static bool isFileSizeWithinLimits(int sizeInBytes,
      [int maxSize = AppConstants.maxFileSize]) {
    return sizeInBytes <= maxSize;
  }

  // Get file extension from path or URL
  static String getFileExtension(String filePathOrUrl) {
    return path.extension(filePathOrUrl).toLowerCase().replaceFirst('.', '');
  }

  // Check if file has a valid extension
  static bool isValidFileExtension(
      String filePathOrUrl, List<String> allowedExtensions) {
    final extension = getFileExtension(filePathOrUrl);
    return allowedExtensions.contains(extension);
  }

  // Clean up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);

      if (await dir.exists()) {
        await for (final file in dir.list()) {
          if (file is File) {
            try {
              await file.delete();
            } catch (e) {
              debugPrint('Error deleting temporary file: ${e.toString()}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temporary files: ${e.toString()}');
    }
  }
}

// Callback for progress reporting
typedef ProgressCallback = void Function(int received, int total);

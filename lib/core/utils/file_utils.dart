// lib/core/utils/file_utils.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';
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

  // Save file from URL - FIXED VERSION
  static Future<File> saveFileFromUrl(
    String url,
    String filename, {
    String? directoryPath,
    Function(int received, int total)? onReceiveProgress,
  }) async {
    try {
      // Create a temporary file path
      final tempDir = await getTemporaryDirectory();
      final tempPath = directoryPath ?? tempDir.path;
      final uniqueId =
          const Uuid().v4(); // Generate unique ID to avoid conflicts
      final filePath = '$tempPath/$uniqueId-$filename';
      final file = File(filePath);

      // Create parent directory if it doesn't exist
      if (!(await file.parent.exists())) {
        await file.parent.create(recursive: true);
      }

      // Construct the proper URL with base URL if needed
      Uri uri;

      // Check if URL is already absolute
      if (url.startsWith('http://') || url.startsWith('https://')) {
        uri = Uri.parse(url);
      }
      // Check if it's an absolute path
      else if (url.startsWith('/')) {
        // Combine with base URL
        final baseUrl = ApiConstants.baseUrl;
        uri = Uri.parse('$baseUrl$url');
      }
      // Relative path
      else {
        // Combine with base URL
        final baseUrl = ApiConstants.baseUrl;
        uri = Uri.parse('$baseUrl/$url');
      }

      // Log the URL being used
      debugPrint('Downloading file from: $uri');

      // Download the file using http package
      final client = http.Client();
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw AppError(
          message:
              'Failed to download file. Server returned ${response.statusCode}',
          type: AppErrorType.network,
        );
      }

      // Get the total file size
      final contentLength = response.contentLength ?? response.bodyBytes.length;

      // Write file with progress reporting
      await file.writeAsBytes(
        response.bodyBytes,
        flush: true,
      );

      // Report 100% progress when done
      if (onReceiveProgress != null && contentLength > 0) {
        onReceiveProgress(contentLength, contentLength);
      }

      client.close();
      return file;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Error saving file from URL: ${e.toString()}',
        type: AppErrorType.network,
      );
    }
  }

  // Save file to downloads directory (mobile)
  static Future<String?> saveFileToDownloads(
    File file,
    String filename,
  ) async {
    try {
      // For iOS and Android
      if (Platform.isIOS || Platform.isAndroid) {
        final params = SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: filename,
        );

        return await FlutterFileDialog.saveFile(params: params);
      }
      // For desktop platforms
      else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Get downloads directory
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          throw AppError(
            message: 'Could not find downloads directory',
            type: AppErrorType.fileSystem,
          );
        }

        // Create the file path in downloads
        final savePath = '${downloadsDir.path}/$filename';

        // Copy the file to downloads
        await file.copy(savePath);

        return savePath;
      }

      throw AppError(
        message: 'Platform not supported for downloads',
        type: AppErrorType.fileSystem,
      );
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Error saving file to downloads: ${e.toString()}',
        type: AppErrorType.fileSystem,
      );
    }
  }

  // Open file with default app
  static Future<void> openFile(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        throw AppError(
          message: 'File does not exist: $filePath',
          type: AppErrorType.fileMissing,
        );
      }

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        throw AppError(
          message: 'Failed to open file: ${result.message}',
          type: AppErrorType.fileAccess,
        );
      }
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
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

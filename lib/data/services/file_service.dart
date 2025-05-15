// lib/data/services/file_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/data/services/storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class FileService {
  final StorageService _storageService;

  FileService({required StorageService storageService})
      : _storageService = storageService;

  // Pick a PDF file from device
  Future<PdfFile?> pickPdfFile() async {
    return FileUtils.pickPdfFile();
  }

  // Pick multiple PDF files from device
  Future<List<PdfFile>> pickMultiplePdfFiles(
      {int maxFiles = AppConstants.maxFilesForMerge}) async {
    return FileUtils.pickMultiplePdfFiles(maxFiles: maxFiles);
  }

  // Get PDF file info (page count, etc.)
  Future<Map<String, dynamic>> getPdfInfo(PdfFile file) async {
    if (file.file == null) {
      throw AppError(
        message: 'File not found',
        type: AppErrorType.fileMissing,
      );
    }

    try {
      // For now, we'll use a simple implementation that just returns basic info
      final info = {
        'name': file.name,
        'size': file.size,
        'extension': file.extension,
        'pageCount': file.pageCount ?? 0,
        'lastModified': file.lastModified.toIso8601String(),
      };

      return info;
    } catch (e) {
      throw AppError(
        message: 'Failed to get PDF info: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Download file from URL
  Future<File> downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw AppError(
          message:
              'Failed to download file. Server returned ${response.statusCode}',
          type: AppErrorType.network,
        );
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${const Uuid().v4()}_$fileName';
      final file = File(filePath);

      // Write file to disk
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Error downloading file: ${e.toString()}',
        type: AppErrorType.network,
      );
    }
  }

  // Save file to app's documents directory
  Future<File> saveFileToDocuments(File file, String fileName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final savedFilePath = '${documentsDir.path}/$fileName';
      final savedFile = await file.copy(savedFilePath);

      // Store file record in local storage
      await _storageService.saveFileRecord(
        name: fileName,
        path: savedFilePath,
        size: await savedFile.length(),
        timestamp: DateTime.now(),
      );

      return savedFile;
    } catch (e) {
      throw AppError(
        message: 'Error saving file: ${e.toString()}',
        type: AppErrorType.fileSystem,
      );
    }
  }

  // Save file to downloads directory (platform specific)
  Future<String?> saveFileToDownloads(File file, String fileName) async {
    return FileUtils.saveFileToDownloads(file, fileName);
  }

  // Open file with default app
  Future<void> openFile(String filePath) async {
    return FileUtils.openFile(filePath);
  }

  // Get temporary file path
  Future<String> getTempFilePath(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/${const Uuid().v4()}_$fileName';
  }

  // Create empty file for writing
  Future<File> createEmptyFile(String fileName) async {
    final tempPath = await getTempFilePath(fileName);
    return File(tempPath).create();
  }

  // Delete file
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw AppError(
        message: 'Error deleting file: ${e.toString()}',
        type: AppErrorType.fileSystem,
      );
    }
  }

  // Get list of recent files
  Future<List<PdfFile>> getRecentFiles() async {
    try {
      final records = await _storageService.getRecentFiles();

      // Convert storage records to PdfFile objects
      final files = <PdfFile>[];
      for (final record in records) {
        final file = File(record.path);
        if (await file.exists()) {
          files.add(
            PdfFile(
              name: record.name,
              path: record.path,
              size: record.size,
              lastModified: record.timestamp,
              file: file,
              extension: path.extension(record.name).replaceFirst('.', ''),
            ),
          );
        }
      }

      return files;
    } catch (e) {
      throw AppError(
        message: 'Error getting recent files: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Clean up temporary files
  Future<void> cleanupTempFiles() async {
    return FileUtils.cleanupTempFiles();
  }
}

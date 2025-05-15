// lib/data/repositories/pdf_repository.dart

import 'dart:io';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_service.dart';
import 'package:megapdf_flutter_client/data/models/compression_result.dart';
import 'package:megapdf_flutter_client/data/models/conversion_result.dart';
import 'package:megapdf_flutter_client/data/models/merge_result.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/data/models/repair_result.dart';
import 'package:megapdf_flutter_client/data/models/sign_result.dart';
import 'package:megapdf_flutter_client/data/models/split_result.dart';
import 'package:megapdf_flutter_client/data/services/file_service.dart';

class PdfRepository {
  final ApiService _apiService;
  final FileService _fileService;

  PdfRepository({
    required ApiService apiService,
    required FileService fileService,
  })  : _apiService = apiService,
        _fileService = fileService;

  // Get PDF info
  Future<Map<String, dynamic>> getPdfInfo(PdfFile file) async {
    if (file.file == null) {
      throw AppError(
        message: 'File not found',
        type: AppErrorType.fileMissing,
      );
    }

    try {
      // Try to get cached page count first
      if (file.pageCount != null) {
        return {
          'pageCount': file.pageCount,
          'name': file.name,
          'size': file.size,
        };
      }

      // Get info from API
      final response = await _apiService.getPdfInfo(file: file.file!);

      if (!response.success) {
        throw AppError(
          message: response.error ?? 'Failed to get PDF info',
          type: AppErrorType.server,
        );
      }

      return response.data ?? {};
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to get PDF info: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Compress PDF
  Future<CompressionResult> compressPdf({
    required PdfFile file,
    required int quality,
  }) async {
    if (file.file == null) {
      throw AppError(
        message: 'File not found',
        type: AppErrorType.fileMissing,
      );
    }

    try {
      final response = await _apiService.compressPdf(
        file: file.file!,
        quality: quality,
      );

      if (!response.success) {
        throw AppError(
          message: response.error ?? 'Failed to compress PDF',
          type: AppErrorType.server,
        );
      }

      final result = response.data!;

      // Save operation to recent files
      await _fileService.saveFileToDocuments(
        await _fileService.downloadFile(result.fileUrl, result.filename),
        result.filename,
      );

      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to compress PDF: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Convert PDF
  Future<ConversionResult> convertPdf({
    required PdfFile file,
    required String outputFormat,
  }) async {
    if (file.file == null) {
      throw AppError(
        message: 'File not found',
        type: AppErrorType.fileMissing,
      );
    }

    try {
      final response = await _apiService.convertPdf(
        file: file.file!,
        outputFormat: outputFormat,
      );

      if (!response.success) {
        throw AppError(
          message: response.error ?? 'Failed to convert PDF',
          type: AppErrorType.server,
        );
      }

      final result = response.data!;

      // Save operation to recent files
      await _fileService.saveFileToDocuments(
        await _fileService.downloadFile(result.fileUrl, result.filename),
        result.filename,
      );

      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to convert PDF: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Merge PDFs
  Future<MergeResult> mergePdfs({
    required List<PdfFile> files,
  }) async {
    // Validate files
    if (files.isEmpty) {
      throw AppError(
        message: 'No files to merge',
        type: AppErrorType.validation,
      );
    }

    // Check if all files have the file property
    for (final file in files) {
      if (file.file == null) {
        throw AppError(
          message: 'File ${file.name} not found',
          type: AppErrorType.fileMissing,
        );
      }
    }

    try {
      final fileObjects = files.map((f) => f.file!).toList();
      final response = await _apiService.mergePdfs(files: fileObjects);

      if (!response.success) {
        throw AppError(
          message: response.error ?? 'Failed to merge PDFs',
          type: AppErrorType.server,
        );
      }

      final result = response.data!;

      // Save operation to recent files
      await _fileService.saveFileToDocuments(
        await _fileService.downloadFile(result.fileUrl, result.filename),
        result.filename,
      );

      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to merge PDFs: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Split PDF
  Future<SplitResult> splitPdf({
    required PdfFile file,
    required List<int> pages,
    bool extractAsIndividualFiles = false,
  }) async {
    if (file.file == null) {
      throw AppError(
        message: 'File not found',
        type: AppErrorType.fileMissing,
      );
    }

    try {
      final response = await _apiService.splitPdf(
        file: file.file!,
        pages: pages,
        extractAsIndividualFiles: extractAsIndividualFiles,
      );

      if (!response.success) {
        throw AppError(
          message: response.error ?? 'Failed to split PDF',
          type: AppErrorType.server,
        );
      }

      final result = response.data!;

      // If the job is not a large job, download and save the files
      if (!result.isLargeJob && result.splitParts != null) {
        for (final part in result.splitParts!) {
          await _fileService.saveFileToDocuments(
            await _fileService.downloadFile(part.fileUrl, part.filename),
            part.filename,
          );
        }
      }

      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to split PDF: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Protect PDF
  Future<dynamic> protectPdf({
    required PdfFile file,
    required String password,
    bool restrictPrinting = true,
    bool restrictEditing = true,
    bool restrictCopying = true,
  }) async {
    if (file.file == null) {
      throw AppError(
        message: 'File not found',
        type: AppErrorType.fileMissing,
      );
    }

    try {
      final response = await _apiService.protectPdf(
        file: file.file!,
        password: password,
        restrictPrinting: restrictPrinting,
        restrictEditing: restrictEditing,
        restrictCopying: restrictCopying,
      );

      if (!response.success) {
        throw AppError(
          message: response.error ?? 'Failed to protect PDF',
          type: AppErrorType.server,
        );
      }

      final result = response.data!;

      // Save operation to recent files
      await _fileService.saveFileToDocuments(
        await _fileService.downloadFile(result['fileUrl'], result['filename']),
        result['filename'],
      );

      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to protect PDF: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Repair PDF
  Future<RepairResult> repairPdf({
    required PdfFile file,
  }) async {
    if (file.file == null) {
      throw AppError(
        message: 'File not found',
        type: AppErrorType.fileMissing,
      );
    }

    try {
      final response = await _apiService.repairPdf(file: file.file!);

      if (!response.success) {
        throw AppError(
          message: response.error ?? 'Failed to repair PDF',
          type: AppErrorType.server,
        );
      }

      final result = response.data!;

      // Save operation to recent files
      await _fileService.saveFileToDocuments(
        await _fileService.downloadFile(result.fileUrl, result.filename),
        result.filename,
      );

      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to repair PDF: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Sign PDF
  Future<SignResult> signPdf({
    required PdfFile file,
    required List<dynamic> signatures,
    required List<dynamic> textElements,
  }) async {
    if (file.file == null) {
      throw AppError(
        message: 'File not found',
        type: AppErrorType.fileMissing,
      );
    }

    try {
      final response = await _apiService.signPdf(
        file: file.file!,
        signatures: signatures,
        textElements: textElements,
      );

      if (!response.success) {
        throw AppError(
          message: response.error ?? 'Failed to sign PDF',
          type: AppErrorType.server,
        );
      }

      final result = response.data!;

      // Save operation to recent files
      await _fileService.saveFileToDocuments(
        await _fileService.downloadFile(result.fileUrl, result.filename),
        result.filename,
      );

      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to sign PDF: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Download file
  Future<File> downloadFile(String url, String fileName) async {
    try {
      return await _fileService.downloadFile(url, fileName);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to download file: ${e.toString()}',
        type: AppErrorType.network,
      );
    }
  }

  // Save file to downloads directory
  Future<String?> saveFileToDownloads(File file, String fileName) async {
    try {
      return await _fileService.saveFileToDownloads(file, fileName);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to save file: ${e.toString()}',
        type: AppErrorType.fileSystem,
      );
    }
  }

  // Open file
  Future<void> openFile(String filePath) async {
    try {
      return await _fileService.openFile(filePath);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Failed to open file: ${e.toString()}',
        type: AppErrorType.fileSystem,
      );
    }
  }
}

// lib/providers/file_service_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/data/services/file_service.dart';
import 'package:megapdf_flutter_client/data/services/storage_service.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// File service provider
final fileServiceProvider = Provider<FileService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return FileService(storageService: storageService);
});

// Recent files provider
final recentFilesProvider = FutureProvider<List<PdfFile>>((ref) async {
  final fileService = ref.watch(fileServiceProvider);
  return fileService.getRecentFiles();
});

// Selected file provider
final selectedFileProvider = StateProvider<PdfFile?>((ref) {
  return null;
});

// File info provider
final fileInfoProvider =
    FutureProvider.family<Map<String, dynamic>, PdfFile>((ref, file) async {
  final fileService = ref.watch(fileServiceProvider);
  return fileService.getPdfInfo(file);
});

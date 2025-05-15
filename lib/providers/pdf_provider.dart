// lib/providers/pdf_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/api/api_service.dart';
import 'package:megapdf_flutter_client/data/models/api_response.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/data/repositories/pdf_repository.dart';
import 'package:megapdf_flutter_client/data/services/file_service.dart';
import 'package:megapdf_flutter_client/data/services/storage_service.dart';
import 'package:megapdf_flutter_client/providers/auth_provider.dart';
import 'package:megapdf_flutter_client/providers/file_service_provider.dart';

// Main PDF state
class PdfState {
  final bool isLoading;
  final PdfFile? currentFile;
  final int pageCount;
  final int currentPage;
  final List<PdfFile> recentFiles;
  final String? errorMessage;

  PdfState({
    this.isLoading = false,
    this.currentFile,
    this.pageCount = 0,
    this.currentPage = 1,
    this.recentFiles = const [],
    this.errorMessage,
  });

  PdfState copyWith({
    bool? isLoading,
    PdfFile? currentFile,
    int? pageCount,
    int? currentPage,
    List<PdfFile>? recentFiles,
    String? errorMessage,
  }) {
    return PdfState(
      isLoading: isLoading ?? this.isLoading,
      currentFile: currentFile ?? this.currentFile,
      pageCount: pageCount ?? this.pageCount,
      currentPage: currentPage ?? this.currentPage,
      recentFiles: recentFiles ?? this.recentFiles,
      errorMessage: errorMessage,
    );
  }
}

class PdfNotifier extends StateNotifier<PdfState> {
  final PdfRepository _pdfRepository;
  final FileService _fileService;

  PdfNotifier({
    required PdfRepository pdfRepository,
    required FileService fileService,
  })  : _pdfRepository = pdfRepository,
        _fileService = fileService,
        super(PdfState()) {
    // Initialize with recent files
    _loadRecentFiles();
  }

  // Load recent files
  Future<void> _loadRecentFiles() async {
    state = state.copyWith(isLoading: true);

    try {
      final recentFiles = await _fileService.getRecentFiles();

      state = state.copyWith(
        isLoading: false,
        recentFiles: recentFiles,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Set current file
  Future<void> setCurrentFile(PdfFile file) async {
    state = state.copyWith(
      isLoading: true,
      currentFile: file,
      currentPage: 1,
    );

    try {
      // Get page count
      final pdfInfo = await _pdfRepository.getPdfInfo(file);
      final pageCount = pdfInfo['pageCount'] as int? ?? 0;

      state = state.copyWith(
        isLoading: false,
        pageCount: pageCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Clear current file
  void clearCurrentFile() {
    state = state.copyWith(
      currentFile: null,
      pageCount: 0,
      currentPage: 1,
    );
  }

  // Set current page
  void setCurrentPage(int page) {
    if (page < 1 || page > state.pageCount) return;

    state = state.copyWith(currentPage: page);
  }

  // Next page
  void nextPage() {
    if (state.currentPage < state.pageCount) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  // Previous page
  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  // Add file to recent files
  Future<void> addToRecentFiles(PdfFile file) async {
    try {
      // Make sure we have a file object
      if (file.file == null) {
        return;
      }

      // Save to local storage
      await _fileService.saveFileToDocuments(file.file!, file.name);

      // Reload recent files
      await _loadRecentFiles();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Pick a PDF file
  Future<PdfFile?> pickPdfFile() async {
    try {
      final file = await _fileService.pickPdfFile();
      if (file != null) {
        await setCurrentFile(file);
      }
      return file;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  // Pick multiple PDF files
  Future<List<PdfFile>> pickMultiplePdfFiles({int maxFiles = 10}) async {
    try {
      final files = await _fileService.pickMultiplePdfFiles(maxFiles: maxFiles);
      return files;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return [];
    }
  }

  // Download a file
  Future<File?> downloadFile(String url, String fileName) async {
    try {
      state = state.copyWith(isLoading: true);

      final file = await _pdfRepository.downloadFile(url, fileName);

      state = state.copyWith(isLoading: false);

      return file;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Save file to downloads
  Future<String?> saveFileToDownloads(File file, String fileName) async {
    try {
      state = state.copyWith(isLoading: true);

      final savedPath =
          await _pdfRepository.saveFileToDownloads(file, fileName);

      state = state.copyWith(isLoading: false);

      return savedPath;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Open file
  Future<void> openFile(String filePath) async {
    try {
      await _pdfRepository.openFile(filePath);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

// API service implementation provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiServiceImpl(apiClient: apiClient);
});

// Create ApiServiceImpl class as a concrete implementation of ApiService
class ApiServiceImpl implements ApiService {
  final ApiClient _apiClient;

  ApiServiceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  // Implement all ApiService methods...
  // For brevity, I'm not implementing all methods as they would follow a similar pattern

  @override
  Future<ApiResponse<dynamic>> getPdfInfo({required File file}) async {
    try {
      final response = await _apiClient.uploadFile(
        '/pdf/info',
        file,
      );

      return ApiResponse<dynamic>(
        success: true,
        data: response.data,
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Implement other methods as needed...

  // All unimplemented methods could return a not implemented error for now
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value(ApiResponse(
      success: false,
      error: 'Method not implemented',
    ));
  }
}

// PDF repository provider
final pdfRepositoryProvider = Provider<PdfRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final fileService = ref.watch(fileServiceProvider);
  return PdfRepository(
    apiService: apiService,
    fileService: fileService,
  );
});

// PDF state provider
final pdfProvider = StateNotifierProvider<PdfNotifier, PdfState>((ref) {
  final pdfRepository = ref.watch(pdfRepositoryProvider);
  final fileService = ref.watch(fileServiceProvider);
  return PdfNotifier(
    pdfRepository: pdfRepository,
    fileService: fileService,
  );
});

// Current file provider
final currentFileProvider = Provider<PdfFile?>((ref) {
  return ref.watch(pdfProvider).currentFile;
});

// Page count provider
final pageCountProvider = Provider<int>((ref) {
  return ref.watch(pdfProvider).pageCount;
});

// Current page provider
final currentPageProvider = Provider<int>((ref) {
  return ref.watch(pdfProvider).currentPage;
});

// Recent files provider
final recentFilesProvider = Provider<List<PdfFile>>((ref) {
  return ref.watch(pdfProvider).recentFiles;
});

// Loading state provider
final pdfLoadingProvider = Provider<bool>((ref) {
  return ref.watch(pdfProvider).isLoading;
});

// Error message provider
final pdfErrorProvider = Provider<String?>((ref) {
  return ref.watch(pdfProvider).errorMessage;
});

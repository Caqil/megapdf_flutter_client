// lib/data/api/api_service.dart

import 'dart:io';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/models/api_response.dart';
import 'package:megapdf_flutter_client/data/models/compression_result.dart';
import 'package:megapdf_flutter_client/data/models/conversion_result.dart';
import 'package:megapdf_flutter_client/data/models/merge_result.dart';
import 'package:megapdf_flutter_client/data/models/repair_result.dart';
import 'package:megapdf_flutter_client/data/models/sign_result.dart';
import 'package:megapdf_flutter_client/data/models/split_result.dart';
import 'package:megapdf_flutter_client/data/models/user.dart';

// Abstract API service interface
abstract class ApiService {
  // Authentication
  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  });

  Future<ApiResponse<bool>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<ApiResponse<bool>> validateToken();

  Future<ApiResponse<bool>> logout();

  Future<ApiResponse<bool>> requestPasswordReset({
    required String email,
  });

  Future<ApiResponse<bool>> resetPassword({
    required String token,
    required String password,
  });

  Future<ApiResponse<bool>> verifyEmail({
    required String token,
  });

  // User profile
  Future<ApiResponse<User>> getUserProfile();

  Future<ApiResponse<User>> updateUserProfile({
    required String name,
  });

  Future<ApiResponse<bool>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  // API keys
  Future<ApiResponse<List<dynamic>>> getApiKeys();

  Future<ApiResponse<dynamic>> createApiKey({
    required String name,
  });

  Future<ApiResponse<bool>> deleteApiKey({
    required String id,
  });

  // PDF operations
  Future<ApiResponse<CompressionResult>> compressPdf({
    required File file,
    required int quality,
  });

  Future<ApiResponse<ConversionResult>> convertPdf({
    required File file,
    required String outputFormat,
  });

  Future<ApiResponse<MergeResult>> mergePdfs({
    required List<File> files,
  });

  Future<ApiResponse<SplitResult>> splitPdf({
    required File file,
    required List<int> pages,
    bool extractAsIndividualFiles = false,
  });

  Future<ApiResponse<dynamic>> protectPdf({
    required File file,
    required String password,
    bool restrictPrinting = true,
    bool restrictEditing = true,
    bool restrictCopying = true,
  });

  Future<ApiResponse<dynamic>> unlockPdf({
    required File file,
    required String password,
  });

  Future<ApiResponse<RepairResult>> repairPdf({
    required File file,
  });

  Future<ApiResponse<dynamic>> rotatePdf({
    required File file,
    required int degrees,
    List<int>? pages,
  });

  Future<ApiResponse<dynamic>> addWatermark({
    required File file,
    required String text,
    double opacity = 0.5,
    double rotation = 0,
  });

  Future<ApiResponse<dynamic>> removePages({
    required File file,
    required List<int> pages,
  });

  Future<ApiResponse<dynamic>> addPageNumbers({
    required File file,
    String position = 'bottom-center',
    int startNumber = 1,
  });

  Future<ApiResponse<SignResult>> signPdf({
    required File file,
    required List<dynamic> signatures,
    required List<dynamic> textElements,
  });

  Future<ApiResponse<dynamic>> processPdf({
    required File file,
    required String operation,
    required Map<String, dynamic> parameters,
  });

  // PDF info
  Future<ApiResponse<dynamic>> getPdfInfo({
    required File file,
  });

  // File operations
  Future<ApiResponse<dynamic>> uploadFile({
    required File file,
    String? type,
  });

  Future<ApiResponse<List<dynamic>>> getFiles();

  Future<ApiResponse<bool>> deleteFile({
    required String id,
  });
}

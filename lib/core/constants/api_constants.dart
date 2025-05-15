// lib/core/constants/api_constants.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URLs
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.megapdf.com';
  static String get apiUrl => '$baseUrl/api';

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resetPassword = '/auth/reset-password';
  static const String resetPasswordConfirm = '/auth/reset-password/confirm';
  static const String validateToken = '/auth/validate';

  // User endpoints
  static const String userProfile = '/user/profile';
  static const String userBalance = '/user/balance';
  static const String userPassword = '/user/password';
  static const String userDeposit = '/user/deposit';
  static const String userDepositVerify = '/user/deposit/verify';

  // API Keys endpoints
  static const String apiKeys = '/keys';

  // PDF operations endpoints
  static const String pdfCompress = '/pdf/compress';
  static const String pdfConvert = '/pdf/convert';
  static const String pdfMerge = '/pdf/merge';
  static const String pdfSplit = '/pdf/split';
  static const String pdfSplitStatus = '/pdf/split/status';
  static const String pdfProtect = '/pdf/protect';
  static const String pdfUnlock = '/pdf/unlock';
  static const String pdfUnlockCheck = '/pdf/unlock/check';
  static const String pdfRepair = '/pdf/repair';
  static const String pdfRotate = '/pdf/rotate';
  static const String pdfWatermark = '/pdf/watermark';
  static const String pdfRemove = '/pdf/remove';
  static const String pdfPageNumbers = '/pdf/pagenumber';
  static const String pdfSign = '/pdf/sign';
  static const String pdfSave = '/pdf/save';
  static const String pdfInfo = '/pdf/info';
  static const String pdfProcess = '/pdf/process';
  static const String pdfChat = '/pdf/chat';

  // OCR endpoints
  static const String ocr = '/ocr';
  static const String ocrExtract = '/ocr/extract';

  // File endpoint
  static const String file = '/file';

  // Error codes
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;

  // Timeout durations
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Headers
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';
  static const String bearerToken = 'Bearer';
  static const String apiKey = 'x-api-key';

  // Content Types
  static const String applicationJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';
}

// lib/core/constants/app_constants.dart

class AppConstants {
  // App info
  static const String appName = 'PDF Tools';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Storage keys
  static const String userKey = 'user_data';
  static const String apiKeyKey = 'api_key';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String recentOperationsKey = 'recent_operations';

  // Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxFilesForMerge = 20;
  static const int maxPageCount = 500;
  static const int maxRecentOperations = 10;

  // File types
  static const List<String> pdfExtensions = ['pdf'];
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> documentExtensions = [
    'docx',
    'doc',
    'rtf',
    'txt',
    'odt',
  ];
  static const List<String> spreadsheetExtensions = ['xlsx', 'xls', 'csv'];
  static const List<String> presentationExtensions = ['pptx', 'ppt'];

  // Operation types for analytics
  static const String operationCompress = 'compress';
  static const String operationConvert = 'convert';
  static const String operationMerge = 'merge';
  static const String operationSplit = 'split';
  static const String operationProtect = 'protect';
  static const String operationUnlock = 'unlock';
  static const String operationRepair = 'repair';
  static const String operationRotate = 'rotate';
  static const String operationWatermark = 'watermark';
  static const String operationRemove = 'remove';
  static const String operationPageNumbers = 'pagenumbers';
  static const String operationSign = 'sign';
  static const String operationOcr = 'ocr';

  // Duration constants
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration splashScreenDuration = Duration(seconds: 2);

  // Default values
  static const int defaultCompressionQuality = 70;
  static const String defaultConversionFormat = 'pdf';
  static const double defaultWatermarkOpacity = 0.5;
  static const int defaultFontSize = 12;

  // Error messages
  static const String errorNetworkTitle = 'Connection Error';
  static const String errorNetworkMessage =
      'Please check your internet connection and try again.';
  static const String errorServerTitle = 'Server Error';
  static const String errorServerMessage =
      'We\'re experiencing technical issues. Please try again later.';
  static const String errorUnauthorizedTitle = 'Authentication Error';
  static const String errorUnauthorizedMessage =
      'Your session has expired. Please sign in again.';
  static const String errorGenericTitle = 'Error';
  static const String errorGenericMessage =
      'Something went wrong. Please try again.';
  static const String errorInvalidFileTitle = 'Invalid File';
  static const String errorInvalidFileMessage =
      'The selected file is not valid or supported.';
  static const String errorFileSizeTitle = 'File Too Large';
  static const String errorFileSizeMessage =
      'The selected file exceeds the maximum allowed size.';

  // Success messages
  static const String successOperationTitle = 'Success';
  static const String successDownloadMessage = 'File downloaded successfully.';
  static const String successUploadMessage = 'File uploaded successfully.';
  static const String successConvertMessage = 'File converted successfully.';
  static const String successCompressMessage = 'File compressed successfully.';
  static const String successMergeMessage = 'Files merged successfully.';
  static const String successSplitMessage = 'File split successfully.';
  static const String successProtectMessage = 'File protected successfully.';
  static const String successUnlockMessage = 'File unlocked successfully.';
  static const String successRepairMessage = 'File repaired successfully.';
  static const String successWatermarkMessage = 'Watermark added successfully.';
  static const String successRemoveMessage = 'Pages removed successfully.';
  static const String successPageNumbersMessage =
      'Page numbers added successfully.';
  static const String successSignMessage = 'Document signed successfully.';
  static const String successOcrMessage =
      'OCR processing completed successfully.';
}

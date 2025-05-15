// lib/presentation/router/route_names.dart

class RouteNames {
  // Auth routes
  static const String splash = 'splash';

  // Main app routes
  static const String home = 'home';
  static const String settings = 'settings';
  static const String apiKeys = 'api-keys';

  // PDF operations routes
  static const String compress = 'compress';
  static const String convert = 'convert';
  static const String merge = 'merge';
  static const String split = 'split';
  static const String protect = 'protect';
  static const String unlock = 'unlock';
  static const String repair = 'repair';
  static const String rotate = 'rotate';
  static const String watermark = 'watermark';
  static const String removePage = 'remove-page';
  static const String pageNumbers = 'page-numbers';
  static const String sign = 'sign';
  static const String ocr = 'ocr';

  // Specific conversions
  static const String pdfToImage = 'pdf-to-image';
  static const String pdfToOffice = 'pdf-to-office';
  static const String imageToPdf = 'image-to-pdf';
  static const String officeToPdf = 'office-to-pdf';

  // Result routes
  static const String result = 'result';
  static const String fileViewer = 'file-viewer';

  // Path strings
  static const String splashPath = '/';

  static const String homePath = '/home';
  static const String settingsPath = '/settings';

  static const String compressPath = '/compress';
  static const String convertPath = '/convert';
  static const String mergePath = '/merge';
  static const String splitPath = '/split';
  static const String protectPath = '/protect';
  static const String unlockPath = '/unlock';
  static const String repairPath = '/repair';
  static const String rotatePath = '/rotate';
  static const String watermarkPath = '/watermark';
  static const String removePagePath = '/remove-page';
  static const String pageNumbersPath = '/page-numbers';
  static const String signPath = '/sign';
  static const String ocrPath = '/ocr';

  // Result paths
  static const String resultPath = '/result';
  static const String fileViewerPath = '/file-viewer';
}

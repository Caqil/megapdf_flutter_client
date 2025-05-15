// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/app.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Clean up any leftover temporary files
  await FileUtils.cleanupTempFiles();
  
  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: PDFToolsApp(),
    ),
  );
}

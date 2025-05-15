// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/app.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // await dotenv.load(fileName: '.env');

  // Clean up any leftover temporary files
  await FileUtils.cleanupTempFiles();
  final permissions = [Permission.storage, Permission.camera];
  for (var permission in permissions) {
    if (await permission.isDenied) {
      var result = await permission.request();
      if (result.isPermanentlyDenied) {
        await openAppSettings();
      } else if (result.isDenied) {
        // Optionally show a dialog explaining why the permission is needed
      }
    }
  }
  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: PDFToolsApp(),
    ),
  );
}

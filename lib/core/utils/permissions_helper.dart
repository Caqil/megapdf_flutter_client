// lib/core/utils/permissions_helper.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionsHelper {
  // Check and request storage permission for reading files
  static Future<bool> requestStoragePermission() async {
    // Web platform doesn't need permissions
    if (kIsWeb) return true;

    // iOS doesn't need storage permission for picking files
    if (Platform.isIOS) return true;

    if (Platform.isAndroid) {
      // For Android 13+ (SDK 33+), we need specific permissions
      if (await Permission.photos.request().isGranted) {
        return true;
      }

      // Check storage permission
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }

      return status.isGranted;
    }

    // Default for other platforms
    return true;
  }

  // Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    // Web platform doesn't need specific permission handling
    if (kIsWeb) return true;

    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    return status.isGranted;
  }

  // Check and request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    // Web platform doesn't need specific permission handling
    if (kIsWeb) return true;

    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    return status.isGranted;
  }

  // Check and request storage permission for saving files
  static Future<bool> requestSavePermission() async {
    // Web platform doesn't need permissions
    if (kIsWeb) return true;

    // iOS doesn't need storage permission for saving files through the share sheet
    if (Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;
      if (sdkVersion >= 33) {
        // Android 13+ requires specific media permissions
        final photos = await Permission.photos.status;
        if (photos.isDenied) {
          final result = await Permission.photos.request();
          return result.isGranted;
        }
        return photos.isGranted;
      } else if (sdkVersion >= 29) {
        // Android 10 and 11 require storage permission for external storage
        final status = await Permission.storage.status;
        if (status.isDenied) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        // Android 9 and below need regular storage permission
        final status = await Permission.storage.status;
        if (status.isDenied) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return status.isGranted;
      }
    }

    // Default for other platforms
    return true;
  }

  // Check if a permission is permanently denied
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    if (kIsWeb) return false;

    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    if (kIsWeb) return;

    await openAppSettings();
  }
}

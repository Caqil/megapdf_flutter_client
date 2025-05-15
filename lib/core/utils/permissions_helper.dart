import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionsHelper {
  // Check and request storage permission for reading files
  static Future<bool> requestStoragePermission() async {
    // Web platform doesn't need permissions
    if (kIsWeb) return true;

    // iOS doesn't need storage permission for picking files (handled by file picker)
    if (Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      // Android 13+ (SDK 33+): Use media-specific permissions
      if (sdkVersion >= 33) {
        final status = await Permission.photos.status;
        if (status.isDenied) {
          final result = await Permission.photos.request();
          if (result.isPermanentlyDenied) {
            await openAppSettings();
            return false;
          }
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        // Android 12 and below: Use legacy storage permissions
        final status = await Permission.storage.status;
        if (status.isDenied) {
          final result = await Permission.storage.request();
          if (result.isPermanentlyDenied) {
            await openAppSettings();
            return false;
          }
          return result.isGranted;
        }
        return status.isGranted;
      }
    }

    // Default for other platforms
    return true;
  }

  // Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return result.isGranted;
    }
    return status.isGranted;
  }

  // Check and request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return result.isGranted;
    }
    return status.isGranted;
  }

  // Check and request storage permission for saving files
  static Future<bool> requestSavePermission() async {
    if (kIsWeb) return true;
    if (Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion >= 33) {
        final status = await Permission.photos.status;
        if (status.isDenied) {
          final result = await Permission.photos.request();
          if (result.isPermanentlyDenied) {
            await openAppSettings();
            return false;
          }
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        final status = await Permission.storage.status;
        if (status.isDenied) {
          final result = await Permission.storage.request();
          if (result.isPermanentlyDenied) {
            await openAppSettings();
            return false;
          }
          return result.isGranted;
        }
        return status.isGranted;
      }
    }

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

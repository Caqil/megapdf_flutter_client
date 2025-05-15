// lib/data/services/storage_service.dart

import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// File record for storage
class FileRecord {
  final String name;
  final String path;
  final int size;
  final DateTime timestamp;
  final String? operation;
  final Map<String, dynamic>? metadata;

  FileRecord({
    required this.name,
    required this.path,
    required this.size,
    required this.timestamp,
    this.operation,
    this.metadata,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'timestamp': timestamp.toIso8601String(),
      if (operation != null) 'operation': operation,
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Create from JSON
  factory FileRecord.fromJson(Map<String, dynamic> json) {
    return FileRecord(
      name: json['name'] as String,
      path: json['path'] as String,
      size: json['size'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      operation: json['operation'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class StorageService {
  // Save app settings
  Future<void> saveSettings({
    required String key,
    required dynamic value,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else {
        // Serialize other types to JSON
        await prefs.setString(key, jsonEncode(value));
      }
    } catch (e) {
      throw AppError(
        message: 'Error saving settings: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Get app settings
  Future<dynamic> getSettings({
    required String key,
    dynamic defaultValue,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(key)) {
        return defaultValue;
      }

      return prefs.get(key);
    } catch (e) {
      throw AppError(
        message: 'Error retrieving settings: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Clear specific setting
  Future<void> clearSetting(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      throw AppError(
        message: 'Error clearing setting: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Save file record
  Future<void> saveFileRecord({
    required String name,
    required String path,
    required int size,
    required DateTime timestamp,
    String? operation,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create new record
      final newRecord = FileRecord(
        name: name,
        path: path,
        size: size,
        timestamp: timestamp,
        operation: operation,
        metadata: metadata,
      );

      // Get existing records
      final recordsJson =
          prefs.getStringList(AppConstants.recentOperationsKey) ?? [];
      final records = recordsJson
          .map((json) => FileRecord.fromJson(jsonDecode(json)))
          .toList();

      // Add new record to the beginning
      records.insert(0, newRecord);

      // Limit the number of records
      if (records.length > AppConstants.maxRecentOperations) {
        records.removeRange(
          AppConstants.maxRecentOperations,
          records.length,
        );
      }

      // Save updated records
      final updatedRecordsJson =
          records.map((record) => jsonEncode(record.toJson())).toList();

      await prefs.setStringList(
          AppConstants.recentOperationsKey, updatedRecordsJson);
    } catch (e) {
      throw AppError(
        message: 'Error saving file record: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Get recent files
  Future<List<FileRecord>> getRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson =
          prefs.getStringList(AppConstants.recentOperationsKey) ?? [];

      final records = recordsJson
          .map((json) => FileRecord.fromJson(jsonDecode(json)))
          .toList();

      // Sort by timestamp (most recent first)
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return records;
    } catch (e) {
      throw AppError(
        message: 'Error retrieving recent files: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Clear recent files
  Future<void> clearRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.recentOperationsKey);
    } catch (e) {
      throw AppError(
        message: 'Error clearing recent files: ${e.toString()}',
        type: AppErrorType.unknown,
      );
    }
  }

  // Save API key
  Future<void> saveApiKey(String apiKey) async {
    await saveSettings(key: AppConstants.apiKeyKey, value: apiKey);
  }

  // Get API key
  Future<String?> getApiKey() async {
    return await getSettings(key: AppConstants.apiKeyKey, defaultValue: null);
  }

  // Save theme preference
  Future<void> saveThemePreference(String theme) async {
    await saveSettings(key: AppConstants.themeKey, value: theme);
  }

  // Get theme preference
  Future<String?> getThemePreference() async {
    return await getSettings(key: AppConstants.themeKey, defaultValue: null);
  }

  // Save language preference
  Future<void> saveLanguagePreference(String language) async {
    await saveSettings(key: AppConstants.languageKey, value: language);
  }

  // Get language preference
  Future<String?> getLanguagePreference() async {
    return await getSettings(key: AppConstants.languageKey, defaultValue: null);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepairResult _$RepairResultFromJson(Map<String, dynamic> json) => RepairResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String,
      filename: json['filename'] as String,
      originalName: json['originalName'] as String,
      details: json['details'] == null
          ? null
          : RepairDetails.fromJson(json['details'] as Map<String, dynamic>),
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RepairResultToJson(RepairResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'originalName': instance.originalName,
      'details': instance.details,
      'billing': instance.billing,
    };

RepairDetails _$RepairDetailsFromJson(Map<String, dynamic> json) =>
    RepairDetails(
      fixed: (json['fixed'] as List<dynamic>).map((e) => e as String).toList(),
      warnings:
          (json['warnings'] as List<dynamic>).map((e) => e as String).toList(),
      originalSize: (json['originalSize'] as num).toInt(),
      newSize: (json['newSize'] as num).toInt(),
    );

Map<String, dynamic> _$RepairDetailsToJson(RepairDetails instance) =>
    <String, dynamic>{
      'fixed': instance.fixed,
      'warnings': instance.warnings,
      'originalSize': instance.originalSize,
      'newSize': instance.newSize,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MergeResult _$MergeResultFromJson(Map<String, dynamic> json) => MergeResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String,
      filename: json['filename'] as String,
      mergedSize: (json['mergedSize'] as num).toInt(),
      totalInputSize: (json['totalInputSize'] as num).toInt(),
      fileCount: (json['fileCount'] as num).toInt(),
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MergeResultToJson(MergeResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'mergedSize': instance.mergedSize,
      'totalInputSize': instance.totalInputSize,
      'fileCount': instance.fileCount,
      'billing': instance.billing,
    };

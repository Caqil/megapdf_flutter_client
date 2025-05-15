// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversionResult _$ConversionResultFromJson(Map<String, dynamic> json) =>
    ConversionResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String,
      filename: json['filename'] as String,
      originalName: json['originalName'] as String,
      inputFormat: json['inputFormat'] as String,
      outputFormat: json['outputFormat'] as String,
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConversionResultToJson(ConversionResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'originalName': instance.originalName,
      'inputFormat': instance.inputFormat,
      'outputFormat': instance.outputFormat,
      'billing': instance.billing,
    };

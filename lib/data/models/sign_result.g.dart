// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignResult _$SignResultFromJson(Map<String, dynamic> json) => SignResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      fileUrl: json['fileUrl'] as String,
      filename: json['filename'] as String,
      originalName: json['originalName'] as String,
      ocrComplete: json['ocrComplete'] as bool? ?? false,
      searchablePdfUrl: json['searchablePdfUrl'] as String?,
      searchablePdfFilename: json['searchablePdfFilename'] as String?,
      ocrText: json['ocrText'] as String?,
      ocrTextUrl: json['ocrTextUrl'] as String?,
      ocrError: json['ocrError'] as String?,
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SignResultToJson(SignResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'originalName': instance.originalName,
      'ocrComplete': instance.ocrComplete,
      'searchablePdfUrl': instance.searchablePdfUrl,
      'searchablePdfFilename': instance.searchablePdfFilename,
      'ocrText': instance.ocrText,
      'ocrTextUrl': instance.ocrTextUrl,
      'ocrError': instance.ocrError,
      'billing': instance.billing,
    };

SignatureElement _$SignatureElementFromJson(Map<String, dynamic> json) =>
    SignatureElement(
      id: json['id'] as String,
      type: json['type'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      size: Size.fromJson(json['size'] as Map<String, dynamic>),
      data: json['data'] as String,
      rotation: (json['rotation'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      page: (json['page'] as num).toInt(),
      color: json['color'] as String?,
      fontSize: (json['fontSize'] as num?)?.toInt(),
      fontFamily: json['fontFamily'] as String?,
    );

Map<String, dynamic> _$SignatureElementToJson(SignatureElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'position': instance.position,
      'size': instance.size,
      'data': instance.data,
      'rotation': instance.rotation,
      'scale': instance.scale,
      'page': instance.page,
      'color': instance.color,
      'fontSize': instance.fontSize,
      'fontFamily': instance.fontFamily,
    };

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };

Size _$SizeFromJson(Map<String, dynamic> json) => Size(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$SizeToJson(Size instance) => <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
    };

PageData _$PageDataFromJson(Map<String, dynamic> json) => PageData(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      originalWidth: (json['originalWidth'] as num).toDouble(),
      originalHeight: (json['originalHeight'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$PageDataToJson(PageData instance) => <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'originalWidth': instance.originalWidth,
      'originalHeight': instance.originalHeight,
      'imageUrl': instance.imageUrl,
    };

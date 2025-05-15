// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      error: json['error'] as String?,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      meta: json['meta'] == null
          ? null
          : ApiResponseMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error': instance.error,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'meta': instance.meta,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

ApiResponseMeta _$ApiResponseMetaFromJson(Map<String, dynamic> json) =>
    ApiResponseMeta(
      page: (json['page'] as num?)?.toInt(),
      perPage: (json['perPage'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      lastPage: (json['lastPage'] as num?)?.toInt(),
      nextPageUrl: json['nextPageUrl'] as String?,
      prevPageUrl: json['prevPageUrl'] as String?,
    );

Map<String, dynamic> _$ApiResponseMetaToJson(ApiResponseMeta instance) =>
    <String, dynamic>{
      'page': instance.page,
      'perPage': instance.perPage,
      'total': instance.total,
      'lastPage': instance.lastPage,
      'nextPageUrl': instance.nextPageUrl,
      'prevPageUrl': instance.prevPageUrl,
    };

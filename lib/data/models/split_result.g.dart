// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SplitResult _$SplitResultFromJson(Map<String, dynamic> json) => SplitResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      jobId: json['jobId'] as String?,
      statusUrl: json['statusUrl'] as String?,
      originalName: json['originalName'] as String,
      totalPages: (json['totalPages'] as num).toInt(),
      estimatedSplits: (json['estimatedSplits'] as num).toInt(),
      isLargeJob: json['isLargeJob'] as bool,
      splitParts: (json['splitParts'] as List<dynamic>?)
          ?.map((e) => SplitPart.fromJson(e as Map<String, dynamic>))
          .toList(),
      billing: json['billing'] == null
          ? null
          : BillingInfo.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SplitResultToJson(SplitResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'jobId': instance.jobId,
      'statusUrl': instance.statusUrl,
      'originalName': instance.originalName,
      'totalPages': instance.totalPages,
      'estimatedSplits': instance.estimatedSplits,
      'isLargeJob': instance.isLargeJob,
      'splitParts': instance.splitParts,
      'billing': instance.billing,
    };

SplitPart _$SplitPartFromJson(Map<String, dynamic> json) => SplitPart(
      fileUrl: json['fileUrl'] as String,
      filename: json['filename'] as String,
      pages: (json['pages'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      pageCount: (json['pageCount'] as num).toInt(),
    );

Map<String, dynamic> _$SplitPartToJson(SplitPart instance) => <String, dynamic>{
      'fileUrl': instance.fileUrl,
      'filename': instance.filename,
      'pages': instance.pages,
      'pageCount': instance.pageCount,
    };

SplitJobStatus _$SplitJobStatusFromJson(Map<String, dynamic> json) =>
    SplitJobStatus(
      id: json['id'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      completed: (json['completed'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => SplitPart.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$SplitJobStatusToJson(SplitJobStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'progress': instance.progress,
      'total': instance.total,
      'completed': instance.completed,
      'results': instance.results,
      'error': instance.error,
    };

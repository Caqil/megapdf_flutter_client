// lib/data/models/split_result.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:megapdf_flutter_client/data/models/api_response.dart';

part 'split_result.g.dart';

@JsonSerializable()
class SplitResult extends Equatable {
  final bool success;
  final String message;
  final String? jobId;
  final String? statusUrl;
  final String originalName;
  final int totalPages;
  final int estimatedSplits;
  final bool isLargeJob;
  final List<SplitPart>? splitParts;
  final BillingInfo? billing;

  const SplitResult({
    required this.success,
    required this.message,
    this.jobId,
    this.statusUrl,
    required this.originalName,
    required this.totalPages,
    required this.estimatedSplits,
    required this.isLargeJob,
    this.splitParts,
    this.billing,
  });

  // Factory method to create SplitResult from JSON
  factory SplitResult.fromJson(Map<String, dynamic> json) =>
      _$SplitResultFromJson(json);

  // Convert SplitResult to JSON
  Map<String, dynamic> toJson() => _$SplitResultToJson(this);

  @override
  List<Object?> get props => [
    success,
    message,
    jobId,
    statusUrl,
    originalName,
    totalPages,
    estimatedSplits,
    isLargeJob,
    splitParts,
    billing,
  ];
}

@JsonSerializable()
class SplitPart extends Equatable {
  final String fileUrl;
  final String filename;
  final List<int> pages;
  final int pageCount;

  const SplitPart({
    required this.fileUrl,
    required this.filename,
    required this.pages,
    required this.pageCount,
  });

  // Factory method to create SplitPart from JSON
  factory SplitPart.fromJson(Map<String, dynamic> json) =>
      _$SplitPartFromJson(json);

  // Convert SplitPart to JSON
  Map<String, dynamic> toJson() => _$SplitPartToJson(this);

  @override
  List<Object?> get props => [fileUrl, filename, pages, pageCount];
}

@JsonSerializable()
class SplitJobStatus extends Equatable {
  final String id;
  final String status;
  final int progress;
  final int total;
  final int completed;
  final List<SplitPart> results;
  final String? error;

  const SplitJobStatus({
    required this.id,
    required this.status,
    required this.progress,
    required this.total,
    required this.completed,
    required this.results,
    this.error,
  });

  // Check if job is completed
  bool get isCompleted => status == 'completed';

  // Check if job is in progress
  bool get isProcessing => status == 'processing';

  // Check if job failed
  bool get isError => status == 'error';

  // Factory method to create SplitJobStatus from JSON
  factory SplitJobStatus.fromJson(Map<String, dynamic> json) =>
      _$SplitJobStatusFromJson(json);

  // Convert SplitJobStatus to JSON
  Map<String, dynamic> toJson() => _$SplitJobStatusToJson(this);

  @override
  List<Object?> get props => [
    id,
    status,
    progress,
    total,
    completed,
    results,
    error,
  ];
}

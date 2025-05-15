// lib/data/models/merge_result.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:megapdf_flutter_client/data/models/api_response.dart';

part 'merge_result.g.dart';

@JsonSerializable()
class MergeResult extends Equatable {
  final bool success;
  final String message;
  final String fileUrl;
  final String filename;
  final int mergedSize;
  final int totalInputSize;
  final int fileCount;
  final BillingInfo? billing;

  const MergeResult({
    required this.success,
    required this.message,
    required this.fileUrl,
    required this.filename,
    required this.mergedSize,
    required this.totalInputSize,
    required this.fileCount,
    this.billing,
  });

  // Factory method to create MergeResult from JSON
  factory MergeResult.fromJson(Map<String, dynamic> json) =>
      _$MergeResultFromJson(json);

  // Convert MergeResult to JSON
  Map<String, dynamic> toJson() => _$MergeResultToJson(this);

  @override
  List<Object?> get props => [
    success,
    message,
    fileUrl,
    filename,
    mergedSize,
    totalInputSize,
    fileCount,
    billing,
  ];
}

// lib/data/models/repair_result.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pdf_tools/data/models/api_response.dart';

part 'repair_result.g.dart';

@JsonSerializable()
class RepairResult extends Equatable {
  final bool success;
  final String message;
  final String fileUrl;
  final String filename;
  final String originalName;
  final RepairDetails? details;
  final BillingInfo? billing;

  const RepairResult({
    required this.success,
    required this.message,
    required this.fileUrl,
    required this.filename,
    required this.originalName,
    this.details,
    this.billing,
  });

  // Factory method to create RepairResult from JSON
  factory RepairResult.fromJson(Map<String, dynamic> json) => _$RepairResultFromJson(json);

  // Convert RepairResult to JSON
  Map<String, dynamic> toJson() => _$RepairResultToJson(this);

  @override
  List<Object?> get props => [
    success,
    message,
    fileUrl,
    filename,
    originalName,
    details,
    billing,
  ];
}

@JsonSerializable()
class RepairDetails extends Equatable {
  final List<String> fixed;
  final List<String> warnings;
  final int originalSize;
  final int newSize;

  const RepairDetails({
    required this.fixed,
    required this.warnings,
    required this.originalSize,
    required this.newSize,
  });

  // Calculate size change percentage
  double get sizeChangePercentage {
    if (originalSize == 0) return 0;
    return (newSize - originalSize) / originalSize * 100;
  }

  // Get size change as a formatted string
  String get sizeChangeFormatted {
    final percentage = sizeChangePercentage;
    final sign = percentage > 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(2)}%';
  }

  // Factory method to create RepairDetails from JSON
  factory RepairDetails.fromJson(Map<String, dynamic> json) => _$RepairDetailsFromJson(json);

  // Convert RepairDetails to JSON
  Map<String, dynamic> toJson() => _$RepairDetailsToJson(this);

  @override
  List<Object?> get props => [fixed, warnings, originalSize, newSize];
}
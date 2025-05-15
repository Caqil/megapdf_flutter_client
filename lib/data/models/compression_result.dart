// lib/data/models/compression_result.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pdf_tools/data/models/api_response.dart';

part 'compression_result.g.dart';

@JsonSerializable()
class CompressionResult extends Equatable {
  final bool success;
  final String message;
  final String fileUrl;
  final String filename;
  final String originalName;
  final int originalSize;
  final int compressedSize;
  final String compressionRatio;
  final BillingInfo? billing;

  const CompressionResult({
    required this.success,
    required this.message,
    required this.fileUrl,
    required this.filename,
    required this.originalName,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    this.billing,
  });

  // Get reduction percentage as a double
  double get reductionPercentage {
    // Remove % sign and convert to double
    final percentString = compressionRatio.replaceAll('%', '').trim();
    try {
      return double.parse(percentString);
    } catch (e) {
      return 0.0;
    }
  }

  // Factory method to create CompressionResult from JSON
  factory CompressionResult.fromJson(Map<String, dynamic> json) =>
      _$CompressionResultFromJson(json);

  // Convert CompressionResult to JSON
  Map<String, dynamic> toJson() => _$CompressionResultToJson(this);

  @override
  List<Object?> get props => [
    success,
    message,
    fileUrl,
    filename,
    originalName,
    originalSize,
    compressedSize,
    compressionRatio,
    billing,
  ];
}

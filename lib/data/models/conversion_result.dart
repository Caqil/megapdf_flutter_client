// lib/data/models/conversion_result.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pdf_tools/data/models/api_response.dart';

part 'conversion_result.g.dart';

@JsonSerializable()
class ConversionResult extends Equatable {
  final bool success;
  final String message;
  final String fileUrl;
  final String filename;
  final String originalName;
  final String inputFormat;
  final String outputFormat;
  final BillingInfo? billing;

  const ConversionResult({
    required this.success,
    required this.message,
    required this.fileUrl,
    required this.filename,
    required this.originalName,
    required this.inputFormat,
    required this.outputFormat,
    this.billing,
  });

  // Factory method to create ConversionResult from JSON
  factory ConversionResult.fromJson(Map<String, dynamic> json) =>
      _$ConversionResultFromJson(json);

  // Convert ConversionResult to JSON
  Map<String, dynamic> toJson() => _$ConversionResultToJson(this);

  @override
  List<Object?> get props => [
    success,
    message,
    fileUrl,
    filename,
    originalName,
    inputFormat,
    outputFormat,
    billing,
  ];
}

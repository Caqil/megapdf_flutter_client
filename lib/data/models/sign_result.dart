// lib/data/models/sign_result.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:megapdf_flutter_client/data/models/api_response.dart';

part 'sign_result.g.dart';

@JsonSerializable()
class SignResult extends Equatable {
  final bool success;
  final String message;
  final String fileUrl;
  final String filename;
  final String originalName;
  final bool ocrComplete;
  final String? searchablePdfUrl;
  final String? searchablePdfFilename;
  final String? ocrText;
  final String? ocrTextUrl;
  final String? ocrError;
  final BillingInfo? billing;

  const SignResult({
    required this.success,
    required this.message,
    required this.fileUrl,
    required this.filename,
    required this.originalName,
    this.ocrComplete = false,
    this.searchablePdfUrl,
    this.searchablePdfFilename,
    this.ocrText,
    this.ocrTextUrl,
    this.ocrError,
    this.billing,
  });

  // Factory method to create SignResult from JSON
  factory SignResult.fromJson(Map<String, dynamic> json) =>
      _$SignResultFromJson(json);

  // Convert SignResult to JSON
  Map<String, dynamic> toJson() => _$SignResultToJson(this);

  @override
  List<Object?> get props => [
    success,
    message,
    fileUrl,
    filename,
    originalName,
    ocrComplete,
    searchablePdfUrl,
    searchablePdfFilename,
    ocrText,
    ocrTextUrl,
    ocrError,
    billing,
  ];
}

@JsonSerializable()
class SignatureElement extends Equatable {
  final String id;
  final String type;
  final Position position;
  final Size size;
  final String data;
  final double rotation;
  final double scale;
  final int page;
  final String? color;
  final int? fontSize;
  final String? fontFamily;

  const SignatureElement({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    required this.data,
    required this.rotation,
    required this.scale,
    required this.page,
    this.color,
    this.fontSize,
    this.fontFamily,
  });

  // Factory method to create SignatureElement from JSON
  factory SignatureElement.fromJson(Map<String, dynamic> json) =>
      _$SignatureElementFromJson(json);

  // Convert SignatureElement to JSON
  Map<String, dynamic> toJson() => _$SignatureElementToJson(this);

  @override
  List<Object?> get props => [
    id,
    type,
    position,
    size,
    data,
    rotation,
    scale,
    page,
    color,
    fontSize,
    fontFamily,
  ];
}

@JsonSerializable()
class Position extends Equatable {
  final double x;
  final double y;

  const Position({required this.x, required this.y});

  // Factory method to create Position from JSON
  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

  // Convert Position to JSON
  Map<String, dynamic> toJson() => _$PositionToJson(this);

  @override
  List<Object?> get props => [x, y];
}

@JsonSerializable()
class Size extends Equatable {
  final double width;
  final double height;

  const Size({required this.width, required this.height});

  // Factory method to create Size from JSON
  factory Size.fromJson(Map<String, dynamic> json) => _$SizeFromJson(json);

  // Convert Size to JSON
  Map<String, dynamic> toJson() => _$SizeToJson(this);

  @override
  List<Object?> get props => [width, height];
}

@JsonSerializable()
class PageData extends Equatable {
  final double width;
  final double height;
  final double originalWidth;
  final double originalHeight;
  final String? imageUrl;

  const PageData({
    required this.width,
    required this.height,
    required this.originalWidth,
    required this.originalHeight,
    this.imageUrl,
  });

  // Factory method to create PageData from JSON
  factory PageData.fromJson(Map<String, dynamic> json) =>
      _$PageDataFromJson(json);

  // Convert PageData to JSON
  Map<String, dynamic> toJson() => _$PageDataToJson(this);

  @override
  List<Object?> get props => [
    width,
    height,
    originalWidth,
    originalHeight,
    imageUrl,
  ];
}

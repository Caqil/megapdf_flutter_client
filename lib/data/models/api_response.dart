// lib/data/models/api_response.dart

import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final T? data;
  final ApiResponseMeta? meta;

  ApiResponse({
    required this.success,
    this.message,
    this.error,
    this.data,
    this.meta,
  });

  // Factory to create ApiResponse from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    // Handle different API response structures
    // Some APIs return data directly, some nest it under a data field
    // We'll handle both cases here

    // If we have a direct 'data' field, use it
    final hasDataField = json.containsKey('data');
    final dataValue = hasDataField ? json['data'] : json;

    // Check if we have a success field, otherwise infer from status code or error presence
    final successValue =
        json.containsKey('success')
            ? json['success']
            : !json.containsKey('error');

    // Try to extract metadata if available
    final metaData =
        json.containsKey('meta')
            ? ApiResponseMeta.fromJson(json['meta'] as Map<String, dynamic>)
            : null;

    return ApiResponse<T>(
      success: successValue as bool,
      message: json['message'] as String?,
      error: json['error'] as String?,
      data: hasDataField ? fromJsonT(dataValue) : null,
      meta: metaData,
    );
  }

  // Convert ApiResponse to JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (error != null) 'error': error,
      if (data != null) 'data': toJsonT(data as T),
      if (meta != null) 'meta': meta!.toJson(),
    };
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, error: $error, data: $data, meta: $meta}';
  }
}

@JsonSerializable()
class ApiResponseMeta {
  final int? page;
  final int? perPage;
  final int? total;
  final int? lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  ApiResponseMeta({
    this.page,
    this.perPage,
    this.total,
    this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory ApiResponseMeta.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseMetaFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseMetaToJson(this);
}

// Generic success response
class SuccessResponse {
  final bool success;
  final String message;

  SuccessResponse({required this.success, required this.message});

  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(
      success: json['success'] as bool,
      message: json['message'] as String? ?? 'Operation successful',
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message};
}

// Error response
class ErrorResponse {
  final bool success;
  final String error;
  final dynamic details;

  ErrorResponse({this.success = false, required this.error, this.details});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String? ?? 'Unknown error occurred',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'error': error,
    if (details != null) 'details': details,
  };
}

// Billing info response from PDF operations
class BillingInfo {
  final bool usedFreeOperation;
  final int freeOperationsRemaining;
  final double currentBalance;
  final double operationCost;

  BillingInfo({
    required this.usedFreeOperation,
    required this.freeOperationsRemaining,
    required this.currentBalance,
    required this.operationCost,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) {
    return BillingInfo(
      usedFreeOperation: json['usedFreeOperation'] as bool? ?? false,
      freeOperationsRemaining: json['freeOperationsRemaining'] as int? ?? 0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      operationCost: (json['operationCost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'usedFreeOperation': usedFreeOperation,
    'freeOperationsRemaining': freeOperationsRemaining,
    'currentBalance': currentBalance,
    'operationCost': operationCost,
  };
}

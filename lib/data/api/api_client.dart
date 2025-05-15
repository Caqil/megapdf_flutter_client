import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart'; // Add this import
import 'package:logger/logger.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/interceptors/auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        contentType: ApiConstants.applicationJson,
        responseType: ResponseType.json,
        headers: {
          ApiConstants.accept: ApiConstants.applicationJson,
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor());

    // Add logging interceptor only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          _logger.d(object);
        },
      ));
    }
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final requestOptions = Options(headers: headers);
      if (options != null) {
        requestOptions.method = options.method;
        requestOptions.sendTimeout = options.sendTimeout;
        requestOptions.receiveTimeout = options.receiveTimeout;
        requestOptions.extra = options.extra;
        requestOptions.headers?.addAll(options.headers ?? {});
        requestOptions.responseType = options.responseType;
        requestOptions.contentType = options.contentType;
        requestOptions.validateStatus = options.validateStatus;
        requestOptions.receiveDataWhenStatusError =
            options.receiveDataWhenStatusError;
        requestOptions.followRedirects = options.followRedirects;
        requestOptions.maxRedirects = options.maxRedirects;
        requestOptions.requestEncoder = options.requestEncoder;
        requestOptions.responseDecoder = options.responseDecoder;
        requestOptions.listFormat = options.listFormat;
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppError(message: e.toString());
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final requestOptions = Options(headers: headers);
      if (options != null) {
        requestOptions.method = options.method;
        requestOptions.sendTimeout = options.sendTimeout;
        requestOptions.receiveTimeout = options.receiveTimeout;
        requestOptions.extra = options.extra;
        requestOptions.headers?.addAll(options.headers ?? {});
        requestOptions.responseType = options.responseType;
        requestOptions.contentType = options.contentType;
        requestOptions.validateStatus = options.validateStatus;
        requestOptions.receiveDataWhenStatusError =
            options.receiveDataWhenStatusError;
        requestOptions.followRedirects = options.followRedirects;
        requestOptions.maxRedirects = options.maxRedirects;
        requestOptions.requestEncoder = options.requestEncoder;
        requestOptions.responseDecoder = options.responseDecoder;
        requestOptions.listFormat = options.listFormat;
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppError(message: e.toString());
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final requestOptions = Options(headers: headers);
      if (options != null) {
        requestOptions.method = options.method;
        requestOptions.sendTimeout = options.sendTimeout;
        requestOptions.receiveTimeout = options.receiveTimeout;
        requestOptions.extra = options.extra;
        requestOptions.headers?.addAll(options.headers ?? {});
        requestOptions.responseType = options.responseType;
        requestOptions.contentType = options.contentType;
        requestOptions.validateStatus = options.validateStatus;
        requestOptions.receiveDataWhenStatusError =
            options.receiveDataWhenStatusError;
        requestOptions.followRedirects = options.followRedirects;
        requestOptions.maxRedirects = options.maxRedirects;
        requestOptions.requestEncoder = options.requestEncoder;
        requestOptions.responseDecoder = options.responseDecoder;
        requestOptions.listFormat = options.listFormat;
      }

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppError(message: e.toString());
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final requestOptions = Options(headers: headers);
      if (options != null) {
        requestOptions.method = options.method;
        requestOptions.sendTimeout = options.sendTimeout;
        requestOptions.receiveTimeout = options.receiveTimeout;
        requestOptions.extra = options.extra;
        requestOptions.headers?.addAll(options.headers ?? {});
        requestOptions.responseType = options.responseType;
        requestOptions.contentType = options.contentType;
        requestOptions.validateStatus = options.validateStatus;
        requestOptions.receiveDataWhenStatusError =
            options.receiveDataWhenStatusError;
        requestOptions.followRedirects = options.followRedirects;
        requestOptions.maxRedirects = options.maxRedirects;
        requestOptions.requestEncoder = options.requestEncoder;
        requestOptions.responseDecoder = options.responseDecoder;
        requestOptions.listFormat = options.listFormat;
      }

      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppError(message: e.toString());
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final requestOptions = Options(headers: headers);
      if (options != null) {
        requestOptions.method = options.method;
        requestOptions.sendTimeout = options.sendTimeout;
        requestOptions.receiveTimeout = options.receiveTimeout;
        requestOptions.extra = options.extra;
        requestOptions.headers?.addAll(options.headers ?? {});
        requestOptions.responseType = options.responseType;
        requestOptions.contentType = options.contentType;
        requestOptions.validateStatus = options.validateStatus;
        requestOptions.receiveDataWhenStatusError =
            options.receiveDataWhenStatusError;
        requestOptions.followRedirects = options.followRedirects;
        requestOptions.maxRedirects = options.maxRedirects;
        requestOptions.requestEncoder = options.requestEncoder;
        requestOptions.responseDecoder = options.responseDecoder;
        requestOptions.listFormat = options.listFormat;
      }

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppError(message: e.toString());
    }
  }

  // Upload file
  Future<Response> uploadFile(
    String path,
    File file, {
    String fileKey = 'file',
    String? fileName,
    String? contentType,
    Map<String, dynamic>? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final fileBaseName = fileName ?? file.path.split('/').last;

      // Create form data
      final formDataObj = FormData();

      // Add file
      formDataObj.files.add(
        MapEntry(
          fileKey,
          await MultipartFile.fromFile(
            file.path,
            filename: fileBaseName,
            contentType:
                contentType != null ? MediaType.parse(contentType) : null,
          ),
        ),
      );

      // Add additional form data if provided
      if (formData != null) {
        formData.forEach((key, value) {
          formDataObj.fields.add(MapEntry(key, value.toString()));
        });
      }

      // Set content type to multipart/form-data
      final requestOptions = Options(
        contentType: ApiConstants.multipartFormData,
        headers: headers,
      );

      // Merge with provided options if any
      if (options != null) {
        requestOptions.method = options.method;
        requestOptions.sendTimeout = options.sendTimeout;
        requestOptions.receiveTimeout = options.receiveTimeout;
        requestOptions.extra = options.extra;
        requestOptions.headers?.addAll(options.headers ?? {});
        requestOptions.responseType = options.responseType;
        requestOptions.validateStatus = options.validateStatus;
        requestOptions.receiveDataWhenStatusError =
            options.receiveDataWhenStatusError;
        requestOptions.followRedirects = options.followRedirects;
        requestOptions.maxRedirects = options.maxRedirects;
        requestOptions.requestEncoder = options.requestEncoder;
        requestOptions.responseDecoder = options.responseDecoder;
        requestOptions.listFormat = options.listFormat;
      }

      // Make the request
      final response = await _dio.post(
        path,
        data: formDataObj,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppError(message: e.toString());
    }
  }

  // Upload multiple files
  Future<Response> uploadFiles(
    String path,
    List<File> files, {
    String fileKey = 'files',
    Map<String, dynamic>? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Create form data
      final formDataObj = FormData();

      // Add files
      for (final file in files) {
        final fileName = file.path.split('/').last;
        formDataObj.files.add(
          MapEntry(
            fileKey,
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ),
        );
      }

      // Add additional form data if provided
      if (formData != null) {
        formData.forEach((key, value) {
          formDataObj.fields.add(MapEntry(key, value.toString()));
        });
      }

      // Set content type to multipart/form-data
      final requestOptions = Options(
        contentType: ApiConstants.multipartFormData,
        headers: headers,
      );

      // Merge with provided options if any
      if (options != null) {
        requestOptions.method = options.method;
        requestOptions.sendTimeout = options.sendTimeout;
        requestOptions.receiveTimeout = options.receiveTimeout;
        requestOptions.extra = options.extra;
        requestOptions.headers?.addAll(options.headers ?? {});
        requestOptions.responseType = options.responseType;
        requestOptions.validateStatus = options.validateStatus;
        requestOptions.receiveDataWhenStatusError =
            options.receiveDataWhenStatusError;
        requestOptions.followRedirects = options.followRedirects;
        requestOptions.maxRedirects = options.maxRedirects;
        requestOptions.requestEncoder = options.requestEncoder;
        requestOptions.responseDecoder = options.responseDecoder;
        requestOptions.listFormat = options.listFormat;
      }

      // Make the request
      final response = await _dio.post(
        path,
        data: formDataObj,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppError(message: e.toString());
    }
  }

  // Download file
  Future<Response> downloadFile(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final requestOptions = Options(headers: headers);
      if (options != null) {
        requestOptions.method = options.method;
        requestOptions.sendTimeout = options.sendTimeout;
        requestOptions.receiveTimeout = options.receiveTimeout;
        requestOptions.extra = options.extra;
        requestOptions.headers?.addAll(options.headers ?? {});
        requestOptions.responseType = options.responseType;
        requestOptions.contentType = options.contentType;
        requestOptions.validateStatus = options.validateStatus;
        requestOptions.receiveDataWhenStatusError =
            options.receiveDataWhenStatusError;
        requestOptions.followRedirects = options.followRedirects;
        requestOptions.maxRedirects = options.maxRedirects;
        requestOptions.requestEncoder = options.requestEncoder;
        requestOptions.responseDecoder = options.responseDecoder;
        requestOptions.listFormat = options.listFormat;
      }

      final response = await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppError(message: e.toString());
    }
  }

  // Handle Dio errors
  AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          message: 'Connection timeout',
          type: AppErrorType.network,
        );

      case DioExceptionType.badCertificate:
        return AppError(
          message: 'Bad SSL certificate',
          type: AppErrorType.network,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return AppError(
          message: 'Request cancelled',
          type: AppErrorType.cancel,
        );

      case DioExceptionType.connectionError:
        return AppError(
          message: 'Connection error',
          type: AppErrorType.network,
        );

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return AppError(
            message: 'No internet connection',
            type: AppErrorType.network,
          );
        }
        return AppError(
          message: error.message ?? 'Unknown error occurred',
          type: AppErrorType.unknown,
        );
    }
  }

  // Handle bad response errors
  AppError _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String errorMessage = 'Unknown error';
    if (data is Map<String, dynamic>) {
      errorMessage = data['error'] ?? data['message'] ?? 'Unknown error';
    } else if (data is String) {
      errorMessage = data;
    }

    switch (statusCode) {
      case ApiConstants.badRequest:
        return AppError(
          message: errorMessage,
          code: statusCode,
          type: AppErrorType.badRequest,
        );

      case ApiConstants.unauthorized:
        return AppError(
          message: 'Unauthorized',
          code: statusCode,
          type: AppErrorType.unauthorized,
        );

      case ApiConstants.forbidden:
        return AppError(
          message: 'Forbidden',
          code: statusCode,
          type: AppErrorType.forbidden,
        );

      case ApiConstants.notFound:
        return AppError(
          message: 'Resource not found',
          code: statusCode,
          type: AppErrorType.notFound,
        );

      case ApiConstants.serverError:
      default:
        return AppError(
          message: errorMessage,
          code: statusCode,
          type: AppErrorType.server,
        );
    }
  }
}

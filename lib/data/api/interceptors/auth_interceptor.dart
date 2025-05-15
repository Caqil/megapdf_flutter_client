// lib/data/api/interceptors/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:megapdf_flutter_client/core/constants/api_constants.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  String? _token;
  String? _apiKey;

  // Get token from local storage if not loaded yet
  Future<String?> _getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    return _token;
  }

  // Get API key from local storage if not loaded yet
  Future<String?> _getApiKey() async {
    if (_apiKey != null) return _apiKey;

    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(AppConstants.apiKeyKey);
    return _apiKey;
  }

  // Set token
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  // Set API key
  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.apiKeyKey, apiKey);
  }

  // Clear token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  // Clear API key
  Future<void> clearApiKey() async {
    _apiKey = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.apiKeyKey);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // If request already has an Authorization header, don't modify it
    if (options.headers.containsKey(ApiConstants.authorization)) {
      return handler.next(options);
    }

    final token = await _getToken();
    final apiKey = await _getApiKey();

    // Add Authorization header if token is available
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearerToken} $token';
    }

    // Add API key header if available
    if (apiKey != null && apiKey.isNotEmpty) {
      options.headers[ApiConstants.apiKey] = apiKey;
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle authentication errors
    if (err.response?.statusCode == 401) {
      // Clear token on unauthorized errors
      clearToken();

      // You could add token refresh logic here if needed
    }

    return handler.next(err);
  }
}

// lib/providers/auth_provider.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/error/app_error.dart';
import 'package:megapdf_flutter_client/data/api/api_client.dart';
import 'package:megapdf_flutter_client/data/api/interceptors/auth_interceptor.dart';
import 'package:megapdf_flutter_client/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth state
class AuthState {
  final bool isAuthenticated;
  final bool isInitialized;
  final bool isLoading;
  final User? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isInitialized = false,
    this.isLoading = false,
    this.user,
    this.token,
    this.errorMessage,
  });

  // Create a copy with updated fields
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isInitialized,
    bool? isLoading,
    User? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final AuthInterceptor _authInterceptor;

  AuthNotifier({
    required ApiClient apiClient,
    required AuthInterceptor authInterceptor,
  })  : _apiClient = apiClient,
        _authInterceptor = authInterceptor,
        super(const AuthState()) {
    // Initialize auth state
    _initAuthState();
  }

  // Initialize auth state from local storage
  Future<void> _initAuthState() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userData = prefs.getString(AppConstants.userKey);

      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        await _authInterceptor.setToken(token);

        state = state.copyWith(
          isAuthenticated: true,
          isInitialized: true,
          isLoading: false,
          user: user,
          token: token,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isInitialized: true,
          isLoading: false,
        );
      }
    } catch (e) {
      // Failed to load auth state, initialize as unauthenticated
      state = state.copyWith(
        isAuthenticated: false,
        isInitialized: true,
        isLoading: false,
        errorMessage: 'Failed to initialize auth state',
      );
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data != null && data['token'] != null) {
        final token = data['token'] as String;
        final user = User.fromJson(data['user']);

        // Save auth state
        await _saveAuthState(token, user);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          token: token,
        );
      } else {
        throw AppError(
          message: 'Invalid response from server',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to login: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Register a new user
  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        // Success, proceed to login
        await login(email, password);
      } else {
        throw AppError(
          message: data?['error'] ?? 'Registration failed',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to register: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Clear auth state from local storage
      await _clearAuthState();

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        token: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to logout: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Request password reset
  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.post(
        '/auth/reset-password',
        data: {
          'email': email,
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        state = state.copyWith(isLoading: false);
      } else {
        throw AppError(
          message: data?['error'] ?? 'Failed to request password reset',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to request password reset: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Reset password with token
  Future<void> resetPassword(String token, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.post(
        '/auth/reset-password/confirm',
        data: {
          'token': token,
          'password': password,
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        state = state.copyWith(isLoading: false);
      } else {
        throw AppError(
          message: data?['error'] ?? 'Failed to reset password',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to reset password: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Verify email with token
  Future<void> verifyEmail(String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.get(
        '/auth/verify-email?token=$token',
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        // Update user to mark email as verified
        if (state.user != null) {
          final updatedUser = state.user!.copyWith(isEmailVerified: true);
          await _saveUser(updatedUser);

          state = state.copyWith(
            isLoading: false,
            user: updatedUser,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      } else {
        throw AppError(
          message: data?['error'] ?? 'Failed to verify email',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to verify email: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.post(
        '/auth/verify-email',
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        state = state.copyWith(isLoading: false);
      } else {
        throw AppError(
          message: data?['error'] ?? 'Failed to send verification email',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send verification email: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile(String name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.put(
        '/user/profile',
        data: {
          'name': name,
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        final updatedUser = User.fromJson(data['user']);
        await _saveUser(updatedUser);

        state = state.copyWith(
          isLoading: false,
          user: updatedUser,
        );
      } else {
        throw AppError(
          message: data?['error'] ?? 'Failed to update profile',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.put(
        '/user/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        state = state.copyWith(isLoading: false);
      } else {
        throw AppError(
          message: data?['error'] ?? 'Failed to update password',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update password: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Fetch user profile
  Future<void> fetchProfile() async {
    if (!state.isAuthenticated) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.get('/user/profile');
      final data = response.data;

      if (data != null) {
        final user = state.user?.copyWith(
          balance: data['balance']?.toDouble() ?? 0,
          freeOperationsRemaining: data['freeOperationsRemaining'] ?? 0,
          operations: data['operations'] ?? 0,
          limit: data['limit'] ?? 0,
        );

        if (user != null) {
          await _saveUser(user);

          state = state.copyWith(
            isLoading: false,
            user: user,
          );
        }
      } else {
        throw AppError(
          message: 'Failed to fetch profile',
          type: AppErrorType.server,
        );
      }
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );

      // If unauthorized, logout
      if (e.type == AppErrorType.unauthorized) {
        await logout();
      }

      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch profile: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Save auth state to local storage
  Future<void> _saveAuthState(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
      await _authInterceptor.setToken(token);
    } catch (e) {
      debugPrint('Failed to save auth state: ${e.toString()}');
    }
  }

  // Save user to local storage
  Future<void> _saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Failed to save user: ${e.toString()}');
    }
  }

  // Clear auth state from local storage
  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      await _authInterceptor.clearToken();
    } catch (e) {
      debugPrint('Failed to clear auth state: ${e.toString()}');
    }
  }
}

// Providers
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authInterceptor = ref.watch(authInterceptorProvider);

  return AuthNotifier(
    apiClient: apiClient,
    authInterceptor: authInterceptor,
  );
});

// User provider that is derived from auth state
final userProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

// Auth loading state provider
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
});

// Auth error message provider
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.errorMessage;
});

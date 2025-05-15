// lib/presentation/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_flutter_client/presentation/router/route_names.dart';
import 'package:megapdf_flutter_client/presentation/screens/result/result_screen.dart';

import '../screens/compress/compress_screen.dart';
import '../screens/convert/convert_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/merge/merge_screen.dart';
import '../screens/protect/protect_screen.dart';
import '../screens/repair/repair_screen.dart';
import '../screens/sign/sign_screen.dart';
import '../screens/split/split_screen.dart';

// Provider for the router
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isInitialized = authState.isInitialized;
      
      // If the app is still initializing (checking token), show splash screen
      if (!isInitialized) {
        return RouteNames.splashPath;
      }
      
      // Paths that don't require authentication
      final noAuthRequired = [
        RouteNames.loginPath,
        RouteNames.registerPath,
        RouteNames.forgotPasswordPath,
        RouteNames.resetPasswordPath,
        RouteNames.verifyEmailPath,
      ];
      
      // Going to login screen but already logged in? Go to home
      if (noAuthRequired.contains(state.matchedLocation) && isLoggedIn) {
        return RouteNames.homePath;
      }
      
      // Going to authenticated route but not logged in? Go to login
      if (!noAuthRequired.contains(state.matchedLocation) && 
          !isLoggedIn && 
          state.matchedLocation != RouteNames.splashPath) {
        return RouteNames.loginPath;
      }
      
      // No redirect needed
      return null;
    },
    routes: [
      // Splash and auth routes
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
     
      GoRoute(
        path: RouteNames.forgotPasswordPath,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPasswordPath,
        name: RouteNames.resetPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: RouteNames.verifyEmailPath,
        name: RouteNames.verifyEmail,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return VerifyEmailScreen(token: token);
        },
      ),
      
      // Main app routes
      GoRoute(
        path: RouteNames.homePath,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
  
      GoRoute(
        path: RouteNames.settingsPath,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.apiKeysPath,
        name: RouteNames.apiKeys,
        builder: (context, state) => const ApiKeysScreen(),
      ),
      GoRoute(
        path: RouteNames.balancePath,
        name: RouteNames.balance,
        builder: (context, state) => const BalanceScreen(),
      ),
      GoRoute(
        path: RouteNames.depositFundsPath,
        name: RouteNames.depositFunds,
        builder: (context, state) => const DepositFundsScreen(),
      ),
      
      // PDF operations routes
      GoRoute(
        path: RouteNames.compressPath,
        name: RouteNames.compress,
        builder: (context, state) => const CompressScreen(),
      ),
      GoRoute(
        path: RouteNames.convertPath,
        name: RouteNames.convert,
        builder: (context, state) => const ConvertScreen(),
      ),
      GoRoute(
        path: RouteNames.mergePath,
        name: RouteNames.merge,
        builder: (context, state) => const MergeScreen(),
      ),
      GoRoute(
        path: RouteNames.splitPath,
        name: RouteNames.split,
        builder: (context, state) => const SplitScreen(),
      ),
      GoRoute(
        path: RouteNames.protectPath,
        name: RouteNames.protect,
        builder: (context, state) => const ProtectScreen(),
      ),
      GoRoute(
        path: RouteNames.unlockPath,
        name: RouteNames.unlock,
        builder: (context, state) => const UnlockScreen(),
      ),
      GoRoute(
        path: RouteNames.repairPath,
        name: RouteNames.repair,
        builder: (context, state) => const RepairScreen(),
      ),
      GoRoute(
        path: RouteNames.rotatePath,
        name: RouteNames.rotate,
        builder: (context, state) => const RotateScreen(),
      ),
      GoRoute(
        path: RouteNames.watermarkPath,
        name: RouteNames.watermark,
        builder: (context, state) => const WatermarkScreen(),
      ),
      GoRoute(
        path: RouteNames.removePagePath,
        name: RouteNames.removePage,
        builder: (context, state) => const RemovePageScreen(),
      ),
      GoRoute(
        path: RouteNames.pageNumbersPath,
        name: RouteNames.pageNumbers,
        builder: (context, state) => const PageNumbersScreen(),
      ),
      GoRoute(
        path: RouteNames.signPath,
        name: RouteNames.sign,
        builder: (context, state) => const SignScreen(),
      ),
      GoRoute(
        path: RouteNames.ocrPath,
        name: RouteNames.ocr,
        builder: (context, state) => const OcrScreen(),
      ),
      
      // Result routes
      GoRoute(
        path: RouteNames.resultPath,
        name: RouteNames.result,
        builder: (context, state) {
          final operation = state.uri.queryParameters['operation'] ?? '';
          final fileUrl = state.uri.queryParameters['fileUrl'] ?? '';
          final fileName = state.uri.queryParameters['fileName'] ?? '';
          return ResultScreen(
            operation: operation,
            fileUrl: fileUrl,
            fileName: fileName,
          );
        },
      ),
      GoRoute(
        path: RouteNames.fileViewerPath,
        name: RouteNames.fileViewer,
        builder: (context, state) {
          final fileUrl = state.uri.queryParameters['fileUrl'] ?? '';
          final fileName = state.uri.queryParameters['fileName'] ?? '';
          return FileViewerScreen(
            fileUrl: fileUrl,
            fileName: fileName,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// Splash Screen
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            const FlutterLogo(size: 100),
            const SizedBox(height: 24),
            Text(
              'PDF Tools',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Error Screen
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Page not found',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.homePath),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Additional screens need to be implemented
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: const Center(child: Text('Forgot Password Screen')),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  final String token;
  
  const ResetPasswordScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(child: Text('Reset Password Screen with token: $token')),
    );
  }
}

class VerifyEmailScreen extends StatelessWidget {
  final String token;
  
  const VerifyEmailScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(child: Text('Verify Email Screen with token: $token')),
    );
  }
}

class ApiKeysScreen extends StatelessWidget {
  const ApiKeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Keys')),
      body: const Center(child: Text('API Keys Screen')),
    );
  }
}

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balance')),
      body: const Center(child: Text('Balance Screen')),
    );
  }
}

class DepositFundsScreen extends StatelessWidget {
  const DepositFundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Funds')),
      body: const Center(child: Text('Deposit Funds Screen')),
    );
  }
}

class UnlockScreen extends StatelessWidget {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock PDF')),
      body: const Center(child: Text('Unlock PDF Screen')),
    );
  }
}

class RotateScreen extends StatelessWidget {
  const RotateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rotate PDF')),
      body: const Center(child: Text('Rotate PDF Screen')),
    );
  }
}

class WatermarkScreen extends StatelessWidget {
  const WatermarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Watermark')),
      body: const Center(child: Text('Add Watermark Screen')),
    );
  }
}

class RemovePageScreen extends StatelessWidget {
  const RemovePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remove Pages')),
      body: const Center(child: Text('Remove Pages Screen')),
    );
  }
}

class PageNumbersScreen extends StatelessWidget {
  const PageNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Page Numbers')),
      body: const Center(child: Text('Add Page Numbers Screen')),
    );
  }
}

class OcrScreen extends StatelessWidget {
  const OcrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR')),
      body: const Center(child: Text('OCR Screen')),
    );
  }
}

class FileViewerScreen extends StatelessWidget {
  final String fileUrl;
  final String fileName;
  
  const FileViewerScreen({
    super.key, 
    required this.fileUrl, 
    required this.fileName
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: Center(child: Text('Viewing file: $fileUrl')),
    );
  }
}
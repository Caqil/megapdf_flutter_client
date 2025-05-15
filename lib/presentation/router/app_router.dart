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
import '../screens/settings/settings_screen.dart';
import '../screens/sign/sign_screen.dart';
import '../screens/split/split_screen.dart';
import '../screens/viewer/file_viewer_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: true,
    routes: [
      // Splash screen
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
        // Automatically navigate to home after delay
        redirect: (context, state) async {
          // Add a delay to show splash screen
          await Future.delayed(const Duration(seconds: 2));
          return RouteNames.homePath;
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
        path: RouteNames.repairPath,
        name: RouteNames.repair,
        builder: (context, state) => const RepairScreen(),
      ),
      GoRoute(
        path: RouteNames.signPath,
        name: RouteNames.sign,
        builder: (context, state) => const SignScreen(),
      ),

      // Result routes
      GoRoute(
        path: RouteNames.resultPath,
        name: RouteNames.result,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};
          return ResultScreen(
            operation: extra['operation'] ?? '',
            fileUrl: extra['fileUrl'] ?? '',
            fileName: extra['fileName'] ?? '',
            additionalData: extra,
          );
        },
      ),
      GoRoute(
        path: RouteNames.fileViewerPath,
        name: RouteNames.fileViewer,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};
          return FileViewerScreen(
            fileUrl: extra['fileUrl'] ?? '',
            fileName: extra['fileName'] ?? '',
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

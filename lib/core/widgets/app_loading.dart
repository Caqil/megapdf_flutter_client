// lib/core/widgets/app_loading.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/theme/app_theme.dart';

enum LoadingSize {
  small,
  medium,
  large,
}

class AppLoading extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final bool overlay;
  final String? message;

  const AppLoading({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.overlay = false,
    this.message,
  });

  // Convenience constructors
  factory AppLoading.small(
      {Color? color, bool overlay = false, String? message}) {
    return AppLoading(
      size: LoadingSize.small,
      color: color,
      overlay: overlay,
      message: message,
    );
  }

  factory AppLoading.large(
      {Color? color, bool overlay = false, String? message}) {
    return AppLoading(
      size: LoadingSize.large,
      color: color,
      overlay: overlay,
      message: message,
    );
  }

  factory AppLoading.overlay({Color? color, String? message}) {
    return AppLoading(
      color: color,
      overlay: true,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? Theme.of(context).colorScheme.primary;
    final loadingSize = _getSize();
    final loadingWidget = _buildLoadingWidget(loadingColor, loadingSize);

    if (overlay) {
      return _buildOverlay(context, loadingWidget);
    }

    return message != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              loadingWidget,
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : loadingWidget;
  }

  // Get spinner size based on LoadingSize
  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 24.0;
      case LoadingSize.large:
        return 52.0;
      case LoadingSize.medium:
      default:
        return 36.0;
    }
  }

  // Build loading widget based on size
  Widget _buildLoadingWidget(Color color, double size) {
    return SpinKitFadingCircle(
      color: color,
      size: size,
    );
  }

  // Build overlay with loading widget
  Widget _buildOverlay(BuildContext context, Widget loadingWidget) {
    return Stack(
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Colors.black45,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                loadingWidget,
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Loading overlay that can be shown on top of the entire screen
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? color;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AppLoading.overlay(
            message: message,
            color: color,
          ),
      ],
    );
  }
}

// A full-screen loading page
class AppLoadingPage extends StatelessWidget {
  final String? message;
  final Color? color;

  const AppLoadingPage({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppLoading(
          size: LoadingSize.large,
          message: message,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

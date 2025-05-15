// lib/core/widgets/app_button.dart

import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/core/theme/app_theme.dart';

enum AppButtonType {
  primary,
  secondary,
  text,
  outline,
  error,
  success,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool iconAfterText;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconAfterText = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine button properties based on type and size
    final theme = Theme.of(context);
    final buttonSize = _getButtonSize();
    final buttonColors = _getButtonColors(theme);
    final buttonStyle = _getButtonStyle(buttonColors, buttonSize);
    final loadingColor = buttonColors.foregroundColor;

    // Build button
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: _buildButton(buttonStyle, loadingColor),
    );
  }

  // Get button size
  _ButtonSize _getButtonSize() {
    switch (size) {
      case AppButtonSize.small:
        return _ButtonSize(
          height: 32.0,
          iconSize: 16.0,
          fontSize: 14.0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12.0),
        );
      case AppButtonSize.large:
        return _ButtonSize(
          height: 52.0,
          iconSize: 24.0,
          fontSize: 16.0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
        );
      case AppButtonSize.medium:
      default:
        return _ButtonSize(
          height: 44.0,
          iconSize: 20.0,
          fontSize: 15.0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        );
    }
  }

  // Get button colors
  _ButtonColors _getButtonColors(ThemeData theme) {
    switch (type) {
      case AppButtonType.secondary:
        return _ButtonColors(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          overlayColor: Colors.white.withOpacity(0.1),
        );
      case AppButtonType.text:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor ?? AppColors.primary,
          overlayColor: AppColors.primary.withOpacity(0.1),
        );
      case AppButtonType.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor ?? AppColors.primary,
          overlayColor: AppColors.primary.withOpacity(0.1),
          borderColor: AppColors.primary,
        );
      case AppButtonType.error:
        return _ButtonColors(
          backgroundColor: backgroundColor ?? AppColors.error,
          foregroundColor: textColor ?? Colors.white,
          overlayColor: Colors.white.withOpacity(0.1),
        );
      case AppButtonType.success:
        return _ButtonColors(
          backgroundColor: backgroundColor ?? AppColors.success,
          foregroundColor: textColor ?? Colors.white,
          overlayColor: Colors.white.withOpacity(0.1),
        );
      case AppButtonType.primary:
      default:
        return _ButtonColors(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          overlayColor: Colors.white.withOpacity(0.1),
        );
    }
  }

  // Get button style
  ButtonStyle _getButtonStyle(_ButtonColors colors, _ButtonSize buttonSize) {
    final radius = borderRadius ?? 8.0;

    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (isDisabled || isLoading) {
            return colors.backgroundColor.withOpacity(0.5);
          }
          return colors.backgroundColor;
        },
      ),
      foregroundColor: MaterialStateProperty.all<Color>(colors.foregroundColor),
      overlayColor: MaterialStateProperty.all<Color>(colors.overlayColor),
      padding: MaterialStateProperty.all<EdgeInsets>(buttonSize.padding),
      minimumSize: MaterialStateProperty.all<Size>(
        Size(0, buttonSize.height),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: colors.borderColor != null
              ? BorderSide(color: colors.borderColor!)
              : BorderSide.none,
        ),
      ),
    );
  }

  // Build button based on loading state
  Widget _buildButton(ButtonStyle buttonStyle, Color loadingColor) {
    // Choose the right button widget based on type
    Widget buttonWidget;

    if (type == AppButtonType.text) {
      buttonWidget = TextButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: buttonStyle,
        child: _buildButtonContent(loadingColor),
      );
    } else if (type == AppButtonType.outline) {
      buttonWidget = OutlinedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: buttonStyle,
        child: _buildButtonContent(loadingColor),
      );
    } else {
      buttonWidget = ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: buttonStyle,
        child: _buildButtonContent(loadingColor),
      );
    }

    return buttonWidget;
  }

  // Build button content (text, icon, and/or loading indicator)
  Widget _buildButtonContent(Color loadingColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
        ),
      );
    }

    final buttonSize = _getButtonSize();
    final textWidget = Text(
      label,
      style: TextStyle(
        fontSize: buttonSize.fontSize,
        fontWeight: FontWeight.w500,
      ),
    );

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(
      icon,
      size: buttonSize.iconSize,
      color: iconColor,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconAfterText
          ? [textWidget, const SizedBox(width: 8), iconWidget]
          : [iconWidget, const SizedBox(width: 8), textWidget],
    );
  }
}

// Helper class for button size properties
class _ButtonSize {
  final double height;
  final double iconSize;
  final double fontSize;
  final EdgeInsets padding;

  _ButtonSize({
    required this.height,
    required this.iconSize,
    required this.fontSize,
    required this.padding,
  });
}

// Helper class for button color properties
class _ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;
  final Color? borderColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.overlayColor,
    this.borderColor,
  });
}

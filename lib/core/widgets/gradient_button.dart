import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/theme/app_theme.dart';

enum GradientButtonSize {
  small,
  medium,
  large,
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final GradientButtonSize size;
  final List<Color> gradientColors;
  final bool fullWidth;
  final double? width;

  const GradientButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = GradientButtonSize.medium,
    this.gradientColors = const [
      AppColors.gradientStart,
      AppColors.gradientEnd
    ],
    this.fullWidth = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getButtonHeight();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();
    final borderRadius = _getBorderRadius();

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: buttonHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: isDisabled || isLoading
              ? LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: isDisabled || isLoading
                  ? Colors.transparent
                  : gradientColors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled || isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: Colors.white.withOpacity(0.2),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  double _getButtonHeight() {
    switch (size) {
      case GradientButtonSize.small:
        return 36;
      case GradientButtonSize.large:
        return 56;
      case GradientButtonSize.medium:
      default:
        return 48;
    }
  }

  double _getFontSize() {
    switch (size) {
      case GradientButtonSize.small:
        return 14;
      case GradientButtonSize.large:
        return 18;
      case GradientButtonSize.medium:
      default:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case GradientButtonSize.small:
        return 16;
      case GradientButtonSize.large:
        return 24;
      case GradientButtonSize.medium:
      default:
        return 20;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case GradientButtonSize.small:
        return 8;
      case GradientButtonSize.large:
        return 16;
      case GradientButtonSize.medium:
      default:
        return 12;
    }
  }
}

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Reusable button matching the Leafora design system.
/// Supports filled and outlined styles, inline loading spinner, and disabled states.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.isOutlined = false,
    this.icon,
    this.height = AppSpacing.buttonHeight,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The label text rendered inside the button.
  final String text;

  /// Callback executed when the button is pressed.
  final VoidCallback? onPressed;

  /// When true, replaces button content with an inline loading spinner.
  final bool isLoading;

  /// Controls whether the button is interactive.
  final bool isEnabled;

  /// Whether to render an outlined secondary button instead of a solid primary button.
  final bool isOutlined;

  /// Optional leading icon widget.
  final Widget? icon;

  /// Fixed button height. Defaults to [AppSpacing.buttonHeight] (48.0).
  final double height;

  /// Whether the button expands to fill parent width horizontally.
  final bool isFullWidth;

  /// Optional custom background color override.
  final Color? backgroundColor;

  /// Optional custom text/icon color override.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;

    final primaryBg = isOutlined
        ? Colors.transparent
        : (backgroundColor ?? AppColors.primaryGreen);
    final primaryFg = isOutlined
        ? (foregroundColor ?? AppColors.primaryGreen)
        : (foregroundColor ?? AppColors.warmIvory);

    final borderSide = isOutlined
        ? BorderSide(
            color: effectiveEnabled
                ? (foregroundColor ?? AppColors.primaryGreen)
                : AppColors.secondaryText.withValues(alpha: 0.3),
            width: 1.5,
          )
        : BorderSide.none;

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? AppColors.primaryGreen : AppColors.warmIvory,
          ),
        ),
      );
    } else {
      buttonChild = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.space8),
          ],
          Text(
            text,
            style: AppTextStyles.button.copyWith(
              color: effectiveEnabled
                  ? primaryFg
                  : AppColors.secondaryText.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: primaryBg,
      foregroundColor: primaryFg,
      disabledBackgroundColor: isOutlined
          ? Colors.transparent
          : AppColors.primaryGreen.withValues(alpha: 0.4),
      disabledForegroundColor: AppColors.warmIvory.withValues(alpha: 0.7),
      elevation: 0,
      side: borderSide,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.cardBorderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      minimumSize: Size(isFullWidth ? double.infinity : 0, height),
    );

    final button = ElevatedButton(
      onPressed: effectiveEnabled ? onPressed : null,
      style: buttonStyle,
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: height, child: button);
    }

    return SizedBox(height: height, child: button);
  }
}

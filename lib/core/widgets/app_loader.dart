import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Reusable loading indicator matching the Leafora design system.
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.message,
    this.size = 32.0,
    this.strokeWidth = 3.0,
    this.color = AppColors.primaryGreen,
    this.isCentered = true,
  });

  /// Optional descriptive text displayed below the spinner (e.g. "Loading plants...").
  final String? message;

  /// Dimensions for the circular spinner.
  final double size;

  /// Line thickness of the progress indicator.
  final double strokeWidth;

  /// Color of the spinner. Defaults to [AppColors.primaryGreen].
  final Color color;

  /// Whether the loader should be wrapped in a [Center] widget.
  final bool isCentered;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: AppColors.sageGreen.withValues(alpha: 0.5),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.space16),
          Text(
            message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isCentered) {
      content = Center(child: content);
    }

    return content;
  }
}

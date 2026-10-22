import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Reusable error state display widget with clear iconography, message,
/// and an optional retry action.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryButtonText = 'Try Again',
    this.icon = Icons.error_outline_rounded,
    this.isCard = false,
  });

  /// The descriptive error explanation shown to the user.
  final String message;

  /// Optional heading title. Defaults to 'Something went wrong'.
  final String title;

  /// Optional callback to retry the failed operation.
  final VoidCallback? onRetry;

  /// Custom label for the retry button.
  final String retryButtonText;

  /// Icon displayed at the top of the error state.
  final IconData icon;

  /// When true, renders the error presentation inside a styled Leafora card.
  final bool isCard;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.redAccent, size: 32),
        ),
        const SizedBox(height: AppSpacing.space16),
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.mainText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.space24),
          AppButton(
            text: retryButtonText,
            onPressed: onRetry,
            isFullWidth: false,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.warmIvory,
              size: 18,
            ),
          ),
        ],
      ],
    );

    if (isCard) {
      return Container(
        padding: AppSpacing.screenPaddingAll,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.cardBorderRadius,
          border: Border.all(
            color: AppColors.secondaryText.withValues(alpha: 0.15),
          ),
        ),
        child: content,
      );
    }

    return Padding(
      padding: AppSpacing.screenPaddingAll,
      child: Center(child: content),
    );
  }
}

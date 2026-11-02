import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

/// Reusable empty state view conforming to Leafora design guidelines.
///
/// Displays an icon or custom illustration, title, descriptive message,
/// and an optional call-to-action button.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.eco_outlined,
    this.actionText,
    this.onAction,
    this.customVisual,
    this.isCard = false,
  });

  /// The main heading for the empty state.
  final String title;

  /// Secondary explanation describing why this view is empty.
  final String message;

  /// Icon rendered inside a soft circle if [customVisual] is not provided.
  final IconData icon;

  /// Optional text for the action button.
  final String? actionText;

  /// Optional callback triggered when the action button is tapped.
  final VoidCallback? onAction;

  /// Optional custom illustration or widget overriding the default icon circle.
  final Widget? customVisual;

  /// When true, wraps the empty state inside a styled card.
  final bool isCard;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        customVisual ??
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 36,
              ),
            ),
        const SizedBox(height: AppSpacing.space24),
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.mainText,
          ),
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
        if (actionText != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.space24),
          AppButton(
            text: actionText!,
            onPressed: onAction,
            isFullWidth: false,
          ),
        ],
      ],
    );

    if (isCard) {
      return Container(
        padding: AppSpacing.screenPaddingAll,
        decoration: BoxDecoration(
          color: AppColors.surface,
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

import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../splash/presentation/widgets/splash_logo.dart';

/// Standard branded header for authentication screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoSize = 88.0,
  });

  /// The main heading text.
  final String title;

  /// The explanatory subtitle text.
  final String subtitle;

  /// Diameter/size of the brand logo mark.
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SplashLogo(
          width: logoSize,
          height: logoSize,
        ),
        const SizedBox(height: AppSpacing.space24),
        Text(
          title,
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryText,
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

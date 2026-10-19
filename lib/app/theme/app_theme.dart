import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.warmIvory,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.warmIvory,
        primaryContainer: AppColors.sageGreen,
        onPrimaryContainer: AppColors.darkGreen,
        secondary: AppColors.darkGreen,
        onSecondary: AppColors.warmIvory,
        surface: AppColors.warmIvory,
        onSurface: AppColors.mainText,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.mainText),
        titleTextStyle: AppTextStyles.sectionTitle,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.warmIvory,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        titleLarge: AppTextStyles.sectionTitle,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }
}

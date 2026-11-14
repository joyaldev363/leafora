import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Central botanical scanner illustration card for the AI Doctor screen.
class PlantScannerCard extends StatelessWidget {
  const PlantScannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space24,
        vertical: AppSpacing.space32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.sageGreen.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botanical Radar / Scanning Target Frame
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer radar pulse circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sageGreen.withValues(alpha: 0.35),
                ),
              ),
              // Middle circle
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sageGreen.withValues(alpha: 0.7),
                ),
              ),
              // Inner glowing core
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen,
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              // Corner scanner bracket markers
              Positioned(
                top: 8,
                left: 8,
                child: _buildScannerCorner(true, true),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _buildScannerCorner(true, false),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: _buildScannerCorner(false, true),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: _buildScannerCorner(false, false),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space24),

          // Heading
          const Text(
            'Check Your Plant Health',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space8),

          // Subtitle / Description
          Text(
            'Take a photo of your plant and let AI help you understand its health.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerCorner(bool isTop, bool isLeft) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: AppColors.primaryGreen, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: AppColors.primaryGreen, width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: AppColors.primaryGreen, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: AppColors.primaryGreen, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}

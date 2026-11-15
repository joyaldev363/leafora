import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Preview card displaying the selected or captured plant photo with retake & proceed actions.
class ScanImagePreview extends StatelessWidget {
  const ScanImagePreview({
    super.key,
    required this.imagePath,
    required this.onRetake,
    required this.onProceed,
    required this.onClear,
  });

  final String imagePath;
  final VoidCallback onRetake;
  final VoidCallback onProceed;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.sageGreen,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        children: [
          // Header with status and clear button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sageGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ready for Analysis',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
                tooltip: 'Clear photo',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),

          // Plant Photo Preview Frame
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radius12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  File(imagePath).existsSync()
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.sageGreen,
                          child: const Center(
                            child: Icon(
                              Icons.local_florist_rounded,
                              size: 48,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                  // Retake Floating Badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: onRetake,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Retake',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          // Start Analysis Primary CTA
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius16),
                ),
              ),
              onPressed: onProceed,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 20),
                  SizedBox(width: AppSpacing.space8),
                  Text(
                    'Analyze Plant Health',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

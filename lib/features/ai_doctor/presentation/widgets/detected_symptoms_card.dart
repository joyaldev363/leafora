import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Card presenting observable botanical symptoms detected from the photo analysis.
class DetectedSymptomsCard extends StatelessWidget {
  const DetectedSymptomsCard({
    super.key,
    required this.symptoms,
  });

  final List<String> symptoms;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(
          color: AppColors.sageGreen.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.remove_red_eye_rounded,
                size: 20,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: AppSpacing.space8),
              Text(
                'Detected Symptoms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space16),

          if (symptoms.isEmpty)
            const Text(
              'No negative symptoms identified. Foliage appears healthy.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            )
          else
            ...symptoms.map(
              (symptom) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Text(
                        symptom,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mainText,
                          height: 1.4,
                        ),
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

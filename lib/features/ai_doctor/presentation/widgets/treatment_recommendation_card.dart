import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Card presenting prioritized actionable plant care and recovery steps.
class TreatmentRecommendationCard extends StatelessWidget {
  const TreatmentRecommendationCard({
    super.key,
    required this.recommendations,
  });

  final List<String> recommendations;

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
                Icons.healing_rounded,
                size: 20,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: AppSpacing.space8),
              Text(
                'Treatment Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space16),

          if (recommendations.isEmpty)
            const Text(
              'No specific treatment needed. Maintain your normal plant care schedule.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            )
          else
            ...recommendations.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final rec = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.sageGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mainText,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

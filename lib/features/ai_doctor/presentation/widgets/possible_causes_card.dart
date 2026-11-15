import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Card presenting hypothesized environmental or care causes, clearly labeled as possibilities.
class PossibleCausesCard extends StatelessWidget {
  const PossibleCausesCard({
    super.key,
    required this.possibleCauses,
  });

  final List<String> possibleCauses;

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
                Icons.help_outline_rounded,
                size: 20,
                color: Color(0xFFE65100),
              ),
              SizedBox(width: AppSpacing.space8),
              Text(
                'Possible Causes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Visual symptoms can correlate with multiple environmental factors. These are potential causes to investigate, not definitive diagnoses.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          if (possibleCauses.isEmpty)
            const Text(
              'No underlying environmental risks identified.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            )
          else
            ...possibleCauses.map(
              (cause) => Padding(
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
                        color: Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Text(
                        cause,
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

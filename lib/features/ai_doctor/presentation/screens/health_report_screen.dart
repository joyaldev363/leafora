import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../providers/ai_doctor_provider.dart';
import '../widgets/detected_symptoms_card.dart';
import '../widgets/health_status_card.dart';
import '../widgets/possible_causes_card.dart';
import '../widgets/treatment_recommendation_card.dart';

/// Screen displaying the comprehensive AI botanical diagnosis report.
class HealthReportScreen extends ConsumerWidget {
  const HealthReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiDoctorNotifierProvider);
    final notifier = ref.read(aiDoctorNotifierProvider.notifier);
    final report = aiState.report;

    if (report == null) {
      return Scaffold(
        backgroundColor: AppColors.warmIvory,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen),
            onPressed: () => context.go(RouteNames.aiDoctor),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 54,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: 12),
              const Text(
                'No health report available.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => context.go(RouteNames.aiDoctor),
                child: const Text('Back to Scanner'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen),
          onPressed: () {
            notifier.resetAnalysis();
            context.go(RouteNames.aiDoctor);
          },
        ),
        title: const Text(
          'Health Report',
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppSpacing.screenPaddingHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space12),

              // Section A: Plant Photo Banner with Botanical Overlay
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radius16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radius16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      File(report.imagePath).existsSync()
                          ? Image.file(
                              File(report.imagePath),
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
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      // Plant Name & Diagnosis Badge Overlay
                      Positioned(
                        bottom: 14,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    report.plantName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (report.scientificName != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      report.scientificName!,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'AI Diagnosed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Section B: Overall Health Status Card
              HealthStatusCard(report: report),
              const SizedBox(height: AppSpacing.space16),

              // Section C: Detected Symptoms Card
              DetectedSymptomsCard(symptoms: report.symptoms),
              const SizedBox(height: AppSpacing.space16),

              // Section D: Possible Causes Card (Explicit hypothesis)
              PossibleCausesCard(possibleCauses: report.possibleCauses),
              const SizedBox(height: AppSpacing.space16),

              // Section E: Treatment Recommendations Card
              TreatmentRecommendationCard(
                recommendations: report.treatmentRecommendations,
              ),
              const SizedBox(height: AppSpacing.space24),

              // Section F: Action Buttons
              // 1. Save Health Report Button
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
                  onPressed: aiState.isSaving
                      ? null
                      : () async {
                          final saved = await notifier.saveHealthReport();
                          if (saved && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Health report saved successfully!'),
                                backgroundColor: AppColors.primaryGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  child: aiState.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              aiState.isSaved
                                  ? Icons.check_circle_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.space8),
                            Text(
                              aiState.isSaved
                                  ? 'Report Saved'
                                  : 'Save Health Report',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.space12),

              // 2. Scan Another Plant Button
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGreen,
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius16),
                    ),
                  ),
                  onPressed: () {
                    notifier.resetAnalysis();
                    context.go(RouteNames.aiDoctor);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 20,
                        color: AppColors.primaryGreen,
                      ),
                      SizedBox(width: AppSpacing.space8),
                      Text(
                        'Scan Another Plant',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space32),
            ],
          ),
        ),
      ),
    );
  }
}

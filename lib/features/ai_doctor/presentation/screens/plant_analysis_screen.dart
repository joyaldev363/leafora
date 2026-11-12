import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../providers/ai_doctor_provider.dart';
import '../widgets/analysis_loading_view.dart';

/// Screen displayed during the AI diagnostic evaluation pipeline.
class PlantAnalysisScreen extends ConsumerStatefulWidget {
  const PlantAnalysisScreen({super.key});

  @override
  ConsumerState<PlantAnalysisScreen> createState() => _PlantAnalysisScreenState();
}

class _PlantAnalysisScreenState extends ConsumerState<PlantAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  Future<void> _startAnalysis() async {
    final notifier = ref.read(aiDoctorNotifierProvider.notifier);
    final success = await notifier.analyzePlant();

    if (success && mounted) {
      context.pushReplacement(RouteNames.aiDoctorReport);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiDoctorNotifierProvider);
    final notifier = ref.read(aiDoctorNotifierProvider.notifier);
    final imagePath = aiState.selectedImagePath ?? '';

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Plant Diagnosis',
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingHorizontal,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.space16),

                  // Header Titles
                  const Text(
                    'Analyzing Your Plant',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  const Text(
                    'Please wait while AI checks your plant health.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space32),

                  // Error Display or Animated Scanner
                  if (aiState.errorMessage != null && !aiState.isAnalyzing) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radius16),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          const Text(
                            'Analysis Interrupted',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          Text(
                            aiState.errorMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.space20),
                          SizedBox(
                            width: double.infinity,
                            height: AppSpacing.buttonHeight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radius16),
                                ),
                              ),
                              onPressed: () => _startAnalysis(),
                              child: const Text('Retry Analysis'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          TextButton(
                            onPressed: () {
                              notifier.clearSelectedImage();
                              context.pop();
                            },
                            child: const Text(
                              'Return to Scanner',
                              style: TextStyle(color: AppColors.secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Animated Scanning Beam Over Plant Photo
                    AnalysisLoadingView(
                      imagePath: imagePath,
                      stageMessage: aiState.analysisStage,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.space32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

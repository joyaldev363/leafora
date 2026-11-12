import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../providers/ai_doctor_provider.dart';
import '../widgets/camera_capture_button.dart';
import '../widgets/gallery_picker_button.dart';
import '../widgets/plant_scanner_card.dart';
import '../widgets/scan_image_preview.dart';

/// Main screen for the AI Doctor bottom navigation tab.
///
/// Focuses purely on plant scanning with direct camera capture, gallery selection,
/// image previewing, and initiating diagnostic analysis.
class AiDoctorScreen extends ConsumerWidget {
  const AiDoctorScreen({super.key});

  void _showSourceChoiceDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondaryText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              const Text(
                'Select Photo Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.sageGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Capture leaves in natural indirect light'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref
                      .read(aiDoctorNotifierProvider.notifier)
                      .replaceSelectedImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.sageGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Select an existing photo from your device'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref
                      .read(aiDoctorNotifierProvider.notifier)
                      .replaceSelectedImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiDoctorNotifierProvider);
    final notifier = ref.read(aiDoctorNotifierProvider.notifier);

    // Listen for errors
    ref.listen(aiDoctorNotifierProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppSpacing.screenPaddingHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space20),

              // Minimal Header
              const Text(
                'AI Doctor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your personal plant health assistant',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.space24),

              // Main Botanical Card or Photo Preview
              if (aiState.hasImage) ...[
                ScanImagePreview(
                  imagePath: aiState.selectedImagePath!,
                  onRetake: () => _showSourceChoiceDialog(context, ref),
                  onClear: () => notifier.clearSelectedImage(),
                  onProceed: () {
                    context.push(RouteNames.aiDoctorAnalyze);
                  },
                ),
              ] else ...[
                const PlantScannerCard(),
                const SizedBox(height: AppSpacing.space24),

                // Primary Scan Plant CTA
                CameraCaptureButton(
                  isLoading: aiState.isPickingImage,
                  onPressed: () async {
                    final picked = await notifier.capturePlantImage();
                    if (picked && context.mounted) {
                      // Stay on screen to preview, or proceed
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.space12),

                // Secondary Gallery Picker CTA
                GalleryPickerButton(
                  isLoading: aiState.isPickingImage,
                  onPressed: () async {
                    await notifier.selectImageFromGallery();
                  },
                ),
              ],

              const SizedBox(height: AppSpacing.space28),

              // Helpful Botanical Guidance Box
              Container(
                padding: const EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: AppColors.sageGreen.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capture clear photos for better analysis',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Frame the affected leaf in focus under natural light for high diagnosis accuracy.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Privacy Notice
              const Center(
                child: Text(
                  'Photos are processed privately to evaluate plant health.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}

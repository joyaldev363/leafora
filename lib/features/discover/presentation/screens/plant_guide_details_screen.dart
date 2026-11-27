import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/plant_guide_entity.dart';
import '../providers/discover_provider.dart';
import '../widgets/bookmark_button.dart';

/// Full-screen botanical guide showing watering, sunlight, soil, and care instructions.
class PlantGuideDetailsScreen extends ConsumerWidget {
  const PlantGuideDetailsScreen({
    super.key,
    required this.plantId,
  });

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check in-memory state first for rapid display
    final discoverState = ref.watch(discoverNotifierProvider);
    final cachedGuide = discoverState.popularPlants
            .where((g) => g.id == plantId)
            .firstOrNull ??
        discoverState.guides.where((g) => g.id == plantId).firstOrNull ??
        (discoverState.featuredPlant?.id == plantId
            ? discoverState.featuredPlant
            : null);

    if (cachedGuide != null) {
      return _PlantGuideContentView(guide: cachedGuide);
    }

    final asyncGuide = ref.watch(plantGuideDetailsProvider(plantId));

    return asyncGuide.when(
      data: (guide) {
        if (guide == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(
              child: Text('Plant care guide not found.'),
            ),
          );
        }
        return _PlantGuideContentView(guide: guide);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(child: Text('Error loading guide: $err')),
      ),
    );
  }
}

class _PlantGuideContentView extends ConsumerWidget {
  const _PlantGuideContentView({required this.guide});

  final PlantGuideEntity guide;

  Widget _buildCareTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space12),
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.secondaryText.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: iconColor, size: 24.0),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mainText,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BookmarkButton(
                  isBookmarked: guide.isBookmarked,
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  size: 20.0,
                  onTap: () {
                    ref
                        .read(discoverNotifierProvider.notifier)
                        .toggleBookmark(guide.id, 'guide');
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    guide.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.sageGreen,
                      child: const Center(
                        child: Icon(
                          Icons.local_florist_rounded,
                          size: 64,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botanical Information Body
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.space20),

                  // Name, Category & Difficulty Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guide.plantName,
                              style: AppTextStyles.headingLarge.copyWith(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (guide.scientificName != null) ...[
                              const SizedBox(height: 2.0),
                              Text(
                                guide.scientificName!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryText,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          guide.difficulty,
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space16),

                  // Description
                  Text(
                    guide.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mainText,
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space24),

                  // Care Requirements Section
                  Text(
                    'Care Requirements',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),

                  _buildCareTile(
                    icon: Icons.water_drop_rounded,
                    iconColor: const Color(0xFF2B78E4),
                    bgColor: const Color(0xFFEBF3FC),
                    title: 'Watering',
                    description: guide.watering,
                  ),
                  _buildCareTile(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: const Color(0xFFE59419),
                    bgColor: const Color(0xFFFEF6E9),
                    title: 'Sunlight',
                    description: guide.sunlight,
                  ),
                  _buildCareTile(
                    icon: Icons.grass_rounded,
                    iconColor: AppColors.primaryGreen,
                    bgColor: AppColors.sageGreen.withValues(alpha: 0.5),
                    title: 'Soil Mixture',
                    description: guide.soil,
                  ),
                  _buildCareTile(
                    icon: Icons.eco_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                    title: 'Fertilizing',
                    description: guide.fertilizer,
                  ),

                  const SizedBox(height: AppSpacing.space16),

                  // General Care Instructions
                  if (guide.careInstructions.isNotEmpty) ...[
                    Text(
                      'General Care & Tips',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.space16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: AppColors.secondaryText.withValues(alpha: 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        guide.careInstructions,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.mainText,
                          height: 1.55,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.space40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

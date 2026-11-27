import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/discover_provider.dart';
import '../widgets/daily_plant_tip_card.dart';
import '../widgets/discover_category_list.dart';
import '../widgets/discover_header.dart';
import '../widgets/discover_search_bar.dart';
import '../widgets/discover_section_header.dart';
import '../widgets/featured_plant_card.dart';
import '../widgets/plant_article_card.dart';
import '../widgets/plant_guide_card.dart';
import '../widgets/popular_plants_section.dart';

/// Production Discover Dashboard screen for Leafora.
///
/// Features a compact header, debounced search, category filters, hero featured
/// plant, popular species gallery, daily plant tip, and educational articles.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  Widget _buildSearchResults(BuildContext context, WidgetRef ref, DiscoverState state) {
    if (state.isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      );
    }

    if (!state.hasSearchResults) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.space40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 54.0,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'No Results Found',
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'We couldn\'t find any plants or guides matching "${state.searchQuery}". Try a different keyword.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.searchedGuides.isNotEmpty) ...[
          DiscoverSectionHeader(
            title: 'Matching Plant Guides (${state.searchedGuides.length})',
          ),
          const SizedBox(height: AppSpacing.space12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: AppSpacing.screenPaddingHorizontal,
            itemCount: state.searchedGuides.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.space12),
            itemBuilder: (context, index) {
              final guide = state.searchedGuides[index];
              return PlantGuideCard(
                guide: guide,
                onTap: () {
                  context.push(RouteNames.discoverPlantGuidePath(guide.id));
                },
                onToggleBookmark: () {
                  ref
                      .read(discoverNotifierProvider.notifier)
                      .toggleBookmark(guide.id, 'guide');
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.space24),
        ],
        if (state.searchedArticles.isNotEmpty) ...[
          DiscoverSectionHeader(
            title: 'Matching Articles (${state.searchedArticles.length})',
          ),
          const SizedBox(height: AppSpacing.space12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: AppSpacing.screenPaddingHorizontal,
            itemCount: state.searchedArticles.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.space12),
            itemBuilder: (context, index) {
              final article = state.searchedArticles[index];
              return PlantArticleCard(
                article: article,
                onTap: () {
                  context.push(RouteNames.discoverArticlePath(article.id));
                },
                onToggleBookmark: () {
                  ref
                      .read(discoverNotifierProvider.notifier)
                      .toggleBookmark(article.id, 'article');
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.space24),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoverState = ref.watch(discoverNotifierProvider);
    final notifier = ref.read(discoverNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          backgroundColor: Colors.white,
          onRefresh: () => notifier.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.space16),

                // 1. Discover Header with Bookmark Icon
                DiscoverHeader(
                  savedCount: discoverState.savedCount,
                  onTapSaved: () {
                    ref.invalidate(savedArticlesProvider);
                    ref.invalidate(savedGuidesProvider);
                    context.push(RouteNames.discoverSaved);
                  },
                ),
                const SizedBox(height: AppSpacing.space16),

                // 2. Discover Search Bar
                DiscoverSearchBar(
                  initialQuery: discoverState.searchQuery,
                  onChanged: notifier.onSearchQueryChanged,
                  onClear: notifier.clearSearch,
                ),
                const SizedBox(height: AppSpacing.space16),

                // 3. Search Results Overlay OR Regular Discover Dashboard
                if (discoverState.hasActiveSearch) ...[
                  _buildSearchResults(context, ref, discoverState),
                ] else ...[
                  // 3A. Horizontally Scrollable Categories
                  DiscoverCategoryList(
                    categories: discoverState.categories,
                    selectedCategory: discoverState.selectedCategory,
                    onSelectCategory: notifier.selectCategory,
                  ),
                  const SizedBox(height: AppSpacing.space16),

                  // 3B. Daily Plant Tip Card
                  DailyPlantTipCard(tip: discoverState.dailyTip),
                  const SizedBox(height: AppSpacing.space24),

                  // 3C. Featured Plant Card
                  if (discoverState.featuredPlant != null) ...[
                    FeaturedPlantCard(
                      plant: discoverState.featuredPlant!,
                      onTapExplore: () {
                        context.push(
                          RouteNames.discoverPlantGuidePath(
                            discoverState.featuredPlant!.id,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.space24),
                  ],

                  // 3D. Popular Plants Horizontal Gallery
                  PopularPlantsSection(
                    plants: discoverState.popularPlants,
                    onTapPlant: (plant) {
                      context.push(RouteNames.discoverPlantGuidePath(plant.id));
                    },
                    onViewAll: () {
                      notifier.selectCategory('Indoor Plants');
                    },
                  ),
                  const SizedBox(height: AppSpacing.space24),

                  // 3E. Plant Care Articles Section
                  DiscoverSectionHeader(
                    title: 'Plant Care Guides',
                    subtitle: 'Master the secrets to keeping foliage thriving',
                  ),
                  const SizedBox(height: AppSpacing.space12),

                  if (discoverState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.space32),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: AppSpacing.screenPaddingHorizontal,
                      itemCount: discoverState.articles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.space12),
                      itemBuilder: (context, index) {
                        final article = discoverState.articles[index];
                        return PlantArticleCard(
                          article: article,
                          onTap: () {
                            context.push(
                              RouteNames.discoverArticlePath(article.id),
                            );
                          },
                          onToggleBookmark: () {
                            notifier.toggleBookmark(article.id, 'article');
                          },
                        );
                      },
                    ),
                  const SizedBox(height: AppSpacing.space40),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

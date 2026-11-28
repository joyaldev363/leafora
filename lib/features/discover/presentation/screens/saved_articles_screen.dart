import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/discover_provider.dart';
import '../widgets/plant_article_card.dart';
import '../widgets/plant_guide_card.dart';

/// Screen presenting bookmarked articles and plant guides with un-bookmark actions.
class SavedArticlesScreen extends ConsumerStatefulWidget {
  const SavedArticlesScreen({super.key});

  @override
  ConsumerState<SavedArticlesScreen> createState() =>
      _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends ConsumerState<SavedArticlesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingHorizontal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: AppColors.sageGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              title,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              subtitle,
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

  @override
  Widget build(BuildContext context) {
    final asyncSavedArticles = ref.watch(savedArticlesProvider);
    final asyncSavedGuides = ref.watch(savedGuidesProvider);

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
          'Saved Library',
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.secondaryText,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Articles'),
            Tab(text: 'Plant Guides'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Saved Articles
          asyncSavedArticles.when(
            data: (articles) {
              if (articles.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'No Saved Articles Yet',
                  subtitle:
                      'Tap the bookmark icon on any article in Discover to save it for offline reading.',
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.screenPaddingAll,
                itemCount: articles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.space12),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return PlantArticleCard(
                    article: article,
                    onTap: () {
                      context.push(RouteNames.discoverArticlePath(article.id));
                    },
                    onToggleBookmark: () async {
                      await ref
                          .read(discoverNotifierProvider.notifier)
                          .toggleBookmark(article.id, 'article');
                      ref.invalidate(savedArticlesProvider);
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            ),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),

          // Tab 2: Saved Plant Guides
          asyncSavedGuides.when(
            data: (guides) {
              if (guides.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.menu_book_rounded,
                  title: 'No Saved Plant Guides',
                  subtitle:
                      'Bookmark botanical care guides to easily check watering and sunlight schedules anytime.',
                );
              }

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.screenPaddingAll,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.space12,
                  mainAxisSpacing: AppSpacing.space12,
                  childAspectRatio: 0.72,
                ),
                itemCount: guides.length,
                itemBuilder: (context, index) {
                  final guide = guides[index];
                  return PlantGuideCard(
                    guide: guide,
                    onTap: () {
                      context.push(RouteNames.discoverPlantGuidePath(guide.id));
                    },
                    onToggleBookmark: () async {
                      await ref
                          .read(discoverNotifierProvider.notifier)
                          .toggleBookmark(guide.id, 'guide');
                      ref.invalidate(savedGuidesProvider);
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            ),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/plant_article_entity.dart';
import '../providers/discover_provider.dart';
import '../widgets/bookmark_button.dart';

/// Full-screen article reading view with formatted content and bookmarking.
class ArticleDetailsScreen extends ConsumerWidget {
  const ArticleDetailsScreen({
    super.key,
    required this.articleId,
  });

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check in-memory state first for instant offline responsiveness
    final cachedArticles = ref.watch(discoverNotifierProvider).articles;
    final cached = cachedArticles.where((a) => a.id == articleId).firstOrNull;

    if (cached != null) {
      return _ArticleContentView(article: cached);
    }

    final asyncArticle = ref.watch(articleDetailsProvider(articleId));

    return asyncArticle.when(
      data: (article) {
        if (article == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(
              child: Text('Article not found.'),
            ),
          );
        }
        return _ArticleContentView(article: article);
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
        body: Center(child: Text('Error loading article: $err')),
      ),
    );
  }
}

class _ArticleContentView extends ConsumerWidget {
  const _ArticleContentView({required this.article});

  final PlantArticleEntity article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsible Cover Header
          SliverAppBar(
            expandedHeight: 280.0,
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
                  isBookmarked: article.isBookmarked,
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  size: 20.0,
                  onTap: () {
                    ref
                        .read(discoverNotifierProvider.notifier)
                        .toggleBookmark(article.id, 'article');
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.sageGreen,
                      child: const Center(
                        child: Icon(
                          Icons.article_outlined,
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

          // Article Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.space20),

                  // Category tag & read time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14.0,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        article.readingTime,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space12),

                  // Article Title
                  Text(
                    article.title,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),

                  // Description / Excerpt
                  Text(
                    article.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),

                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.space20),

                  // Formatted Content Sections
                  _FormattedArticleBody(content: article.content),

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

/// Helper parsing markdown-like headings and paragraphs with comfortable typography.
class _FormattedArticleBody extends StatelessWidget {
  const _FormattedArticleBody({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();

        if (trimmed.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              trimmed.substring(2),
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        } else if (trimmed.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
            child: Text(
              trimmed.substring(3),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        } else if (trimmed.startsWith('- ') || trimmed.startsWith('• ')) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Icon(Icons.circle, size: 6.0, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    trimmed.substring(2),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mainText,
                      height: 1.5,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (trimmed.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              trimmed,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mainText,
                height: 1.6,
                fontSize: 14.5,
              ),
            ),
          );
        }

        return const SizedBox(height: 6.0);
      }).toList(),
    );
  }
}

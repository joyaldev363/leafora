import '../entities/discover_category_entity.dart';
import '../entities/plant_article_entity.dart';
import '../entities/plant_guide_entity.dart';

/// Contract interface for Discovery content repository.
abstract interface class DiscoverRepository {
  /// Fetches available discovery categories.
  Future<List<DiscoverCategoryEntity>> getCategories();

  /// Fetches hero featured plant for the discovery banner.
  Future<PlantGuideEntity?> getFeaturedPlant();

  /// Fetches curated list of popular houseplants.
  Future<List<PlantGuideEntity>> getPopularPlants();

  /// Fetches plant care educational articles, optionally filtered by [category].
  Future<List<PlantArticleEntity>> getPlantArticles({String? category});

  /// Fetches botanical plant guides, optionally filtered by [category].
  Future<List<PlantGuideEntity>> getPlantGuides({String? category});

  /// Fetches verified daily plant care advice.
  Future<String> getDailyPlantTip();

  /// Searches plant names, care guides, and articles matching [query].
  Future<Map<String, List<dynamic>>> searchContent(String query);

  /// Retrieves full article by [id].
  Future<PlantArticleEntity?> getArticleById(String id);

  /// Retrieves full plant guide by [id].
  Future<PlantGuideEntity?> getPlantGuideById(String id);

  /// Toggles bookmark state for a given [contentId] of [contentType] ('article' or 'guide').
  /// Returns updated isBookmarked boolean.
  Future<bool> toggleBookmark(String contentId, String contentType);

  /// Retrieves all bookmarked articles.
  Future<List<PlantArticleEntity>> getBookmarkedArticles();

  /// Retrieves all bookmarked plant guides.
  Future<List<PlantGuideEntity>> getBookmarkedGuides();
}

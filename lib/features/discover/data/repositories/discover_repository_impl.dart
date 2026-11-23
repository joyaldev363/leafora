import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/discover_category_entity.dart';
import '../../domain/entities/plant_article_entity.dart';
import '../../domain/entities/plant_guide_entity.dart';
import '../../domain/repositories/discover_repository.dart';
import '../datasources/discover_remote_datasource.dart';

/// Implementation of [DiscoverRepository] bridging remote data and local bookmark state.
class DiscoverRepositoryImpl implements DiscoverRepository {
  DiscoverRepositoryImpl({
    required this.remoteDataSource,
    LocalStorageService? storageService,
  }) : _storage = storageService ?? LocalStorageServiceImpl();

  final DiscoverRemoteDataSource remoteDataSource;
  final LocalStorageService _storage;

  static const String _articleBookmarksKey = 'bookmarked_article_ids';
  static const String _guideBookmarksKey = 'bookmarked_guide_ids';

  // In-memory set cache for rapid lookups and offline resilience
  final Set<String> _bookmarkedArticleIds = {};
  final Set<String> _bookmarkedGuideIds = {};
  bool _bookmarksInitialized = false;

  Future<void> _ensureBookmarksLoaded() async {
    if (_bookmarksInitialized) return;
    try {
      final articleList = _storage.get<List<dynamic>>(
        AppConstants.userPreferencesBox,
        _articleBookmarksKey,
        defaultValue: [],
      );
      if (articleList != null) {
        _bookmarkedArticleIds.addAll(articleList.map((e) => e.toString()));
      }

      final guideList = _storage.get<List<dynamic>>(
        AppConstants.userPreferencesBox,
        _guideBookmarksKey,
        defaultValue: [],
      );
      if (guideList != null) {
        _bookmarkedGuideIds.addAll(guideList.map((e) => e.toString()));
      }
    } catch (e) {
      debugPrint('DiscoverRepository: Warning - loading bookmarks from cache: $e');
    }
    _bookmarksInitialized = true;
  }

  Future<void> _persistBookmarks() async {
    try {
      await _storage.put(
        AppConstants.userPreferencesBox,
        _articleBookmarksKey,
        _bookmarkedArticleIds.toList(),
      );
      await _storage.put(
        AppConstants.userPreferencesBox,
        _guideBookmarksKey,
        _bookmarkedGuideIds.toList(),
      );
    } catch (e) {
      debugPrint('DiscoverRepository: Notice - persisting bookmarks: $e');
    }
  }

  PlantArticleEntity _applyArticleBookmark(PlantArticleEntity article) {
    return article.copyWith(
      isBookmarked: _bookmarkedArticleIds.contains(article.id),
    );
  }

  PlantGuideEntity _applyGuideBookmark(PlantGuideEntity guide) {
    return guide.copyWith(
      isBookmarked: _bookmarkedGuideIds.contains(guide.id),
    );
  }

  @override
  Future<List<DiscoverCategoryEntity>> getCategories() async {
    return remoteDataSource.getCategories();
  }

  @override
  Future<PlantGuideEntity?> getFeaturedPlant() async {
    await _ensureBookmarksLoaded();
    final model = await remoteDataSource.getFeaturedPlant();
    if (model == null) return null;
    return _applyGuideBookmark(model);
  }

  @override
  Future<List<PlantGuideEntity>> getPopularPlants() async {
    await _ensureBookmarksLoaded();
    final list = await remoteDataSource.getPopularPlants();
    return list.map(_applyGuideBookmark).toList();
  }

  @override
  Future<List<PlantArticleEntity>> getPlantArticles({String? category}) async {
    await _ensureBookmarksLoaded();
    final list = await remoteDataSource.getPlantArticles(category: category);
    return list.map(_applyArticleBookmark).toList();
  }

  @override
  Future<List<PlantGuideEntity>> getPlantGuides({String? category}) async {
    await _ensureBookmarksLoaded();
    final list = await remoteDataSource.getPlantGuides(category: category);
    return list.map(_applyGuideBookmark).toList();
  }

  @override
  Future<String> getDailyPlantTip() async {
    return remoteDataSource.getDailyPlantTip();
  }

  @override
  Future<Map<String, List<dynamic>>> searchContent(String query) async {
    await _ensureBookmarksLoaded();
    final raw = await remoteDataSource.searchContent(query);
    final rawArticles = raw['articles'] ?? [];
    final rawGuides = raw['guides'] ?? [];

    final articles = rawArticles
        .whereType<PlantArticleEntity>()
        .map(_applyArticleBookmark)
        .toList();
    final guides = rawGuides
        .whereType<PlantGuideEntity>()
        .map(_applyGuideBookmark)
        .toList();

    return {
      'articles': articles,
      'guides': guides,
    };
  }

  @override
  Future<PlantArticleEntity?> getArticleById(String id) async {
    await _ensureBookmarksLoaded();
    final model = await remoteDataSource.getArticleById(id);
    if (model == null) return null;
    return _applyArticleBookmark(model);
  }

  @override
  Future<PlantGuideEntity?> getPlantGuideById(String id) async {
    await _ensureBookmarksLoaded();
    final model = await remoteDataSource.getPlantGuideById(id);
    if (model == null) return null;
    return _applyGuideBookmark(model);
  }

  @override
  Future<bool> toggleBookmark(String contentId, String contentType) async {
    await _ensureBookmarksLoaded();
    final isGuide = contentType.toLowerCase().contains('guide') ||
        contentType.toLowerCase().contains('plant');

    bool nowBookmarked = false;
    if (isGuide) {
      if (_bookmarkedGuideIds.contains(contentId)) {
        _bookmarkedGuideIds.remove(contentId);
        nowBookmarked = false;
      } else {
        _bookmarkedGuideIds.add(contentId);
        nowBookmarked = true;
      }
    } else {
      if (_bookmarkedArticleIds.contains(contentId)) {
        _bookmarkedArticleIds.remove(contentId);
        nowBookmarked = false;
      } else {
        _bookmarkedArticleIds.add(contentId);
        nowBookmarked = true;
      }
    }

    await _persistBookmarks();
    return nowBookmarked;
  }

  @override
  Future<List<PlantArticleEntity>> getBookmarkedArticles() async {
    await _ensureBookmarksLoaded();
    final all = await remoteDataSource.getPlantArticles();
    return all
        .where((a) => _bookmarkedArticleIds.contains(a.id))
        .map((a) => a.copyWith(isBookmarked: true))
        .toList();
  }

  @override
  Future<List<PlantGuideEntity>> getBookmarkedGuides() async {
    await _ensureBookmarksLoaded();
    final all = await remoteDataSource.getPopularPlants();
    return all
        .where((g) => _bookmarkedGuideIds.contains(g.id))
        .map((g) => g.copyWith(isBookmarked: true))
        .toList();
  }
}

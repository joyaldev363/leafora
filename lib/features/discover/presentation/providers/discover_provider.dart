import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/discover_remote_datasource.dart';
import '../../data/repositories/discover_repository_impl.dart';
import '../../domain/entities/discover_category_entity.dart';
import '../../domain/entities/plant_article_entity.dart';
import '../../domain/entities/plant_guide_entity.dart';
import '../../domain/repositories/discover_repository.dart';
import '../../domain/usecases/get_discover_content_usecase.dart';
import '../../domain/usecases/search_discover_content_usecase.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';

// -----------------------------------------------------------------------------
// Discover State
// -----------------------------------------------------------------------------

class DiscoverState {
  const DiscoverState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.selectedCategory = 'All',
    this.categories = const [],
    this.featuredPlant,
    this.popularPlants = const [],
    this.articles = const [],
    this.guides = const [],
    this.dailyTip = 'Rotate your plants regularly for balanced sunlight growth.',
    this.searchQuery = '',
    this.isSearching = false,
    this.searchedArticles = const [],
    this.searchedGuides = const [],
    this.savedCount = 0,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isRefreshing;
  final String selectedCategory;
  final List<DiscoverCategoryEntity> categories;
  final PlantGuideEntity? featuredPlant;
  final List<PlantGuideEntity> popularPlants;
  final List<PlantArticleEntity> articles;
  final List<PlantGuideEntity> guides;
  final String dailyTip;
  final String searchQuery;
  final bool isSearching;
  final List<PlantArticleEntity> searchedArticles;
  final List<PlantGuideEntity> searchedGuides;
  final int savedCount;
  final String? errorMessage;

  bool get hasActiveSearch => searchQuery.trim().isNotEmpty;
  bool get hasSearchResults =>
      searchedArticles.isNotEmpty || searchedGuides.isNotEmpty;

  DiscoverState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? selectedCategory,
    List<DiscoverCategoryEntity>? categories,
    PlantGuideEntity? featuredPlant,
    List<PlantGuideEntity>? popularPlants,
    List<PlantArticleEntity>? articles,
    List<PlantGuideEntity>? guides,
    String? dailyTip,
    String? searchQuery,
    bool? isSearching,
    List<PlantArticleEntity>? searchedArticles,
    List<PlantGuideEntity>? searchedGuides,
    int? savedCount,
    String? errorMessage,
    bool clearError = false,
    bool clearSearch = false,
  }) {
    return DiscoverState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      featuredPlant: featuredPlant ?? this.featuredPlant,
      popularPlants: popularPlants ?? this.popularPlants,
      articles: articles ?? this.articles,
      guides: guides ?? this.guides,
      dailyTip: dailyTip ?? this.dailyTip,
      searchQuery: clearSearch ? '' : (searchQuery ?? this.searchQuery),
      isSearching: clearSearch ? false : (isSearching ?? this.isSearching),
      searchedArticles:
          clearSearch ? const [] : (searchedArticles ?? this.searchedArticles),
      searchedGuides:
          clearSearch ? const [] : (searchedGuides ?? this.searchedGuides),
      savedCount: savedCount ?? this.savedCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// -----------------------------------------------------------------------------
// Discover Notifier
// -----------------------------------------------------------------------------

class DiscoverNotifier extends StateNotifier<DiscoverState> {
  DiscoverNotifier({
    required this.getDiscoverContentUseCase,
    required this.searchDiscoverContentUseCase,
    required this.toggleBookmarkUseCase,
    required this.repository,
  }) : super(const DiscoverState()) {
    loadDashboard();
  }

  final GetDiscoverContentUseCase getDiscoverContentUseCase;
  final SearchDiscoverContentUseCase searchDiscoverContentUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;
  final DiscoverRepository repository;

  Timer? _debounceTimer;

  Future<void> loadDashboard({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh,
      isRefreshing: isRefresh,
      clearError: true,
    );

    try {
      final dashboardData = await getDiscoverContentUseCase(
        selectedCategory:
            state.selectedCategory == 'All' ? null : state.selectedCategory,
      );

      final savedArticles = await repository.getBookmarkedArticles();
      final savedGuides = await repository.getBookmarkedGuides();
      final totalSaved = savedArticles.length + savedGuides.length;

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        categories: dashboardData.categories,
        featuredPlant: dashboardData.featuredPlant,
        popularPlants: dashboardData.popularPlants,
        articles: dashboardData.articles,
        guides: dashboardData.guides,
        dailyTip: dashboardData.dailyTip,
        savedCount: totalSaved,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: 'Unable to load discover content: $e',
      );
    }
  }

  Future<void> selectCategory(String category) async {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category, isLoading: true);

    try {
      final targetCat = category == 'All' ? null : category;
      final articles = await repository.getPlantArticles(category: targetCat);
      final guides = await repository.getPlantGuides(category: targetCat);

      state = state.copyWith(
        isLoading: false,
        articles: articles,
        guides: guides,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to filter by $category: $e',
      );
    }
  }

  void onSearchQueryChanged(String query) {
    state = state.copyWith(searchQuery: query);

    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(clearSearch: true);
      return;
    }

    state = state.copyWith(isSearching: true);
    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final result = await searchDiscoverContentUseCase(query);
        final articles =
            (result['articles'] ?? []).whereType<PlantArticleEntity>().toList();
        final guides =
            (result['guides'] ?? []).whereType<PlantGuideEntity>().toList();

        state = state.copyWith(
          isSearching: false,
          searchedArticles: articles,
          searchedGuides: guides,
        );
      } catch (e) {
        state = state.copyWith(
          isSearching: false,
          errorMessage: 'Search failed: $e',
        );
      }
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(clearSearch: true);
  }

  Future<void> toggleBookmark(String contentId, String contentType) async {
    final newBookmarkState = await toggleBookmarkUseCase(
      contentId: contentId,
      contentType: contentType,
    );

    // Update in-memory collections reactively
    final isGuide = contentType.toLowerCase().contains('guide') ||
        contentType.toLowerCase().contains('plant');

    if (isGuide) {
      final updatedPopular = state.popularPlants.map((g) {
        return g.id == contentId ? g.copyWith(isBookmarked: newBookmarkState) : g;
      }).toList();

      final updatedGuides = state.guides.map((g) {
        return g.id == contentId ? g.copyWith(isBookmarked: newBookmarkState) : g;
      }).toList();

      final updatedFeatured = state.featuredPlant?.id == contentId
          ? state.featuredPlant?.copyWith(isBookmarked: newBookmarkState)
          : state.featuredPlant;

      final updatedSearchedGuides = state.searchedGuides.map((g) {
        return g.id == contentId ? g.copyWith(isBookmarked: newBookmarkState) : g;
      }).toList();

      state = state.copyWith(
        popularPlants: updatedPopular,
        guides: updatedGuides,
        featuredPlant: updatedFeatured,
        searchedGuides: updatedSearchedGuides,
        savedCount: state.savedCount + (newBookmarkState ? 1 : -1),
      );
    } else {
      final updatedArticles = state.articles.map((a) {
        return a.id == contentId ? a.copyWith(isBookmarked: newBookmarkState) : a;
      }).toList();

      final updatedSearchedArticles = state.searchedArticles.map((a) {
        return a.id == contentId ? a.copyWith(isBookmarked: newBookmarkState) : a;
      }).toList();

      state = state.copyWith(
        articles: updatedArticles,
        searchedArticles: updatedSearchedArticles,
        savedCount: state.savedCount + (newBookmarkState ? 1 : -1),
      );
    }
  }

  Future<void> refresh() => loadDashboard(isRefresh: true);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// -----------------------------------------------------------------------------
// Dependency Providers
// -----------------------------------------------------------------------------

final discoverRemoteDataSourceProvider =
    Provider<DiscoverRemoteDataSource>((ref) {
  return DiscoverRemoteDataSourceImpl();
});

final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  final dataSource = ref.watch(discoverRemoteDataSourceProvider);
  return DiscoverRepositoryImpl(remoteDataSource: dataSource);
});

final getDiscoverContentUseCaseProvider =
    Provider<GetDiscoverContentUseCase>((ref) {
  final repo = ref.watch(discoverRepositoryProvider);
  return GetDiscoverContentUseCase(repo);
});

final searchDiscoverContentUseCaseProvider =
    Provider<SearchDiscoverContentUseCase>((ref) {
  final repo = ref.watch(discoverRepositoryProvider);
  return SearchDiscoverContentUseCase(repo);
});

final toggleBookmarkUseCaseProvider = Provider<ToggleBookmarkUseCase>((ref) {
  final repo = ref.watch(discoverRepositoryProvider);
  return ToggleBookmarkUseCase(repo);
});

final discoverNotifierProvider =
    StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  return DiscoverNotifier(
    getDiscoverContentUseCase: ref.watch(getDiscoverContentUseCaseProvider),
    searchDiscoverContentUseCase:
        ref.watch(searchDiscoverContentUseCaseProvider),
    toggleBookmarkUseCase: ref.watch(toggleBookmarkUseCaseProvider),
    repository: ref.watch(discoverRepositoryProvider),
  );
});

// Single Article Details Provider
final articleDetailsProvider =
    FutureProvider.family<PlantArticleEntity?, String>((ref, articleId) async {
  final repo = ref.watch(discoverRepositoryProvider);
  return repo.getArticleById(articleId);
});

// Single Plant Guide Details Provider
final plantGuideDetailsProvider =
    FutureProvider.family<PlantGuideEntity?, String>((ref, plantId) async {
  final repo = ref.watch(discoverRepositoryProvider);
  return repo.getPlantGuideById(plantId);
});

// Saved Articles Provider
final savedArticlesProvider =
    FutureProvider.autoDispose<List<PlantArticleEntity>>((ref) async {
  final repo = ref.watch(discoverRepositoryProvider);
  return repo.getBookmarkedArticles();
});

// Saved Guides Provider
final savedGuidesProvider =
    FutureProvider.autoDispose<List<PlantGuideEntity>>((ref) async {
  final repo = ref.watch(discoverRepositoryProvider);
  return repo.getBookmarkedGuides();
});

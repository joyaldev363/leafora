import '../entities/discover_category_entity.dart';
import '../entities/plant_article_entity.dart';
import '../entities/plant_guide_entity.dart';
import '../repositories/discover_repository.dart';

class DiscoverDashboardData {
  const DiscoverDashboardData({
    required this.categories,
    required this.featuredPlant,
    required this.popularPlants,
    required this.articles,
    required this.guides,
    required this.dailyTip,
  });

  final List<DiscoverCategoryEntity> categories;
  final PlantGuideEntity? featuredPlant;
  final List<PlantGuideEntity> popularPlants;
  final List<PlantArticleEntity> articles;
  final List<PlantGuideEntity> guides;
  final String dailyTip;
}

class GetDiscoverContentUseCase {
  const GetDiscoverContentUseCase(this._repository);

  final DiscoverRepository _repository;

  Future<DiscoverDashboardData> call({String? selectedCategory}) async {
    final results = await Future.wait([
      _repository.getCategories(),
      _repository.getFeaturedPlant(),
      _repository.getPopularPlants(),
      _repository.getPlantArticles(category: selectedCategory),
      _repository.getPlantGuides(category: selectedCategory),
      _repository.getDailyPlantTip(),
    ]);

    return DiscoverDashboardData(
      categories: results[0] as List<DiscoverCategoryEntity>,
      featuredPlant: results[1] as PlantGuideEntity?,
      popularPlants: results[2] as List<PlantGuideEntity>,
      articles: results[3] as List<PlantArticleEntity>,
      guides: results[4] as List<PlantGuideEntity>,
      dailyTip: results[5] as String,
    );
  }
}

import '../entities/plant_article_entity.dart';
import '../repositories/discover_repository.dart';

class GetPlantArticlesUseCase {
  const GetPlantArticlesUseCase(this._repository);

  final DiscoverRepository _repository;

  Future<List<PlantArticleEntity>> call({String? category}) {
    return _repository.getPlantArticles(category: category);
  }
}

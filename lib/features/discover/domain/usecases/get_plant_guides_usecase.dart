import '../entities/plant_guide_entity.dart';
import '../repositories/discover_repository.dart';

class GetPlantGuidesUseCase {
  const GetPlantGuidesUseCase(this._repository);

  final DiscoverRepository _repository;

  Future<List<PlantGuideEntity>> call({String? category}) {
    return _repository.getPlantGuides(category: category);
  }
}

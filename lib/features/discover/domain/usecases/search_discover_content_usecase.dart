import '../repositories/discover_repository.dart';

class SearchDiscoverContentUseCase {
  const SearchDiscoverContentUseCase(this._repository);

  final DiscoverRepository _repository;

  Future<Map<String, List<dynamic>>> call(String query) {
    return _repository.searchContent(query);
  }
}

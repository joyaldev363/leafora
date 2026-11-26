import '../repositories/discover_repository.dart';

class ToggleBookmarkUseCase {
  const ToggleBookmarkUseCase(this._repository);

  final DiscoverRepository _repository;

  Future<bool> call({required String contentId, required String contentType}) {
    return _repository.toggleBookmark(contentId, contentType);
  }
}

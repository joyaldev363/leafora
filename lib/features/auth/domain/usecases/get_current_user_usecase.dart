import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case that fetches the active session's [UserEntity].
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  UserEntity? call() {
    return _repository.getCurrentUser();
  }
}

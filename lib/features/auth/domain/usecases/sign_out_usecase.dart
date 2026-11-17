import '../repositories/auth_repository.dart';

/// Use case that signs the current user out of their session.
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() async {
    return _repository.signOut();
  }
}

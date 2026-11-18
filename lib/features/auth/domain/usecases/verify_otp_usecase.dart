import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case that verifies a 6-digit OTP code and resolves the authenticated [UserEntity].
class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String phone,
    required String token,
    String? fullName,
  }) async {
    return _repository.verifyOtp(
      phone: phone,
      token: token,
      fullName: fullName,
    );
  }
}

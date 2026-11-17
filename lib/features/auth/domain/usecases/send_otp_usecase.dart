import '../repositories/auth_repository.dart';

/// Use case that dispatches a phone verification OTP to the user.
class SendOtpUseCase {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String phone) async {
    return _repository.sendOtp(phone);
  }
}

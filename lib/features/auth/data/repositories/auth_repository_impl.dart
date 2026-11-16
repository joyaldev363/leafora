import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository] mediating between remote data sources and use cases.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await _remoteDataSource.sendOtp(phone);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error sending verification code: $e',
        details: e,
      );
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    required String phone,
    required String token,
    String? fullName,
  }) async {
    try {
      return await _remoteDataSource.verifyOtp(
        phone: phone,
        token: token,
        fullName: fullName,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error verifying verification code: $e',
        details: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error signing out: $e',
        details: e,
      );
    }
  }

  @override
  UserEntity? getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> updateProfile({required String fullName}) async {
    try {
      return await _remoteDataSource.updateProfile(fullName: fullName);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error updating profile: $e',
        details: e,
      );
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _remoteDataSource.authStateChanges();
  }
}

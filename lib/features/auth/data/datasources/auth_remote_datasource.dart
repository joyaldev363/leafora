import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/app_exception.dart';
import '../../../../services/supabase_service.dart';
import '../models/user_model.dart';

/// Contract for the remote authentication data source.
abstract interface class AuthRemoteDataSource {
  /// Sends OTP via SMS to the target phone number.
  Future<void> sendOtp(String phone);

  /// Verifies the OTP token against Supabase Auth.
  Future<UserModel> verifyOtp({
    required String phone,
    required String token,
    String? fullName,
  });

  /// Terminates the current active session.
  Future<void> signOut();

  /// Returns the currently authenticated user, if any.
  UserModel? getCurrentUser();

  /// Updates profile metadata and database records.
  Future<UserModel> updateProfile({required String fullName});

  /// Emits updates on authentication state changes.
  Stream<UserModel?> authStateChanges();
}

/// Implementation of [AuthRemoteDataSource] powered by [SupabaseService] with
/// seamless local simulation fallback when Supabase credentials are not configured.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({sb.SupabaseClient? client})
      : _customClient = client;

  final sb.SupabaseClient? _customClient;

  // In-memory mock session supporting local UI testing prior to Supabase configuration
  static UserModel? _mockSessionUser;

  bool get _isSupabaseReady {
    if (_customClient != null) return true;
    return SupabaseService.instance.isInitialized;
  }

  sb.SupabaseClient get _client {
    return _customClient ?? SupabaseService.instance.client;
  }

  @override
  Future<void> sendOtp(String phone) async {
    // If Supabase is not yet configured, provide seamless local testing fallback
    if (!_isSupabaseReady) {
      debugPrint(
        'AuthRemoteDataSource (Local Demo Mode): Dispatched OTP simulation to $phone. Use 123456 or any 6 digits.',
      );
      return;
    }

    try {
      await _client.auth.signInWithOtp(
        phone: phone,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.statusCode,
        details: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to dispatch phone verification OTP: $e',
        details: e,
      );
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String phone,
    required String token,
    String? fullName,
  }) async {
    // If Supabase is not yet configured, resolve a local demo user session
    if (!_isSupabaseReady) {
      debugPrint(
        'AuthRemoteDataSource (Local Demo Mode): Verified OTP $token for $phone.',
      );
      _mockSessionUser = UserModel(
        id: 'demo_user_${phone.replaceAll(RegExp(r'\D'), '')}',
        phone: phone,
        fullName: fullName ?? 'Plant Parent',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return _mockSessionUser!;
    }

    try {
      final response = await _client.auth.verifyOTP(
        type: sb.OtpType.sms,
        token: token,
        phone: phone,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          message:
              'Verification succeeded but no active user session was returned.',
        );
      }

      if (fullName != null && fullName.trim().isNotEmpty) {
        return await updateProfile(fullName: fullName.trim());
      }

      return UserModel.fromSupabaseUser(user);
    } on sb.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.statusCode,
        details: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(
        message: 'Error verifying OTP code: $e',
        details: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    if (!_isSupabaseReady) {
      _mockSessionUser = null;
      return;
    }

    try {
      await _client.auth.signOut();
    } on sb.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.statusCode,
        details: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to sign out: $e',
        details: e,
      );
    }
  }

  @override
  UserModel? getCurrentUser() {
    if (!_isSupabaseReady) {
      return _mockSessionUser;
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      debugPrint('AuthRemoteDataSource: getCurrentUser error: $e');
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile({required String fullName}) async {
    if (!_isSupabaseReady) {
      if (_mockSessionUser != null) {
        _mockSessionUser = UserModel(
          id: _mockSessionUser!.id,
          phone: _mockSessionUser!.phone,
          fullName: fullName,
          createdAt: _mockSessionUser!.createdAt,
          updatedAt: DateTime.now(),
        );
        return _mockSessionUser!;
      }
      return UserModel(
        id: 'demo_user',
        phone: '+919876543210',
        fullName: fullName,
        createdAt: DateTime.now(),
      );
    }

    try {
      final response = await _client.auth.updateUser(
        sb.UserAttributes(
          data: {'full_name': fullName},
        ),
      );

      final updatedUser = response.user;
      if (updatedUser == null) {
        throw const AuthException(
          message: 'Failed to retrieve updated profile from server.',
        );
      }

      try {
        await _client.from('profiles').upsert({
          'id': updatedUser.id,
          'full_name': fullName,
          'phone': updatedUser.phone,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (tableError) {
        debugPrint(
          'AuthRemoteDataSource: Notice - profiles table sync skipped: $tableError',
        );
      }

      return UserModel.fromSupabaseUser(updatedUser);
    } on sb.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.statusCode,
        details: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(
        message: 'Failed to update user profile: $e',
        details: e,
      );
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    if (!_isSupabaseReady) {
      return Stream.value(_mockSessionUser);
    }

    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }
}

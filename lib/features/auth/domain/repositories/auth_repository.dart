import '../entities/user_entity.dart';

/// Contract defining authentication operations for the application.
abstract interface class AuthRepository {
  /// Sends a one-time verification password (OTP) via SMS to [phone].
  Future<void> sendOtp(String phone);

  /// Verifies the provided 6-digit [token] for [phone].
  ///
  /// Optionally attaches [fullName] if the user is completing registration.
  Future<UserEntity> verifyOtp({
    required String phone,
    required String token,
    String? fullName,
  });

  /// Terminates the current active user session.
  Future<void> signOut();

  /// Retrieves the currently authenticated user, or null if unauthenticated.
  UserEntity? getCurrentUser();

  /// Updates profile metadata and database records with [fullName].
  Future<UserEntity> updateProfile({required String fullName});

  /// Broadcasts authentication state transitions.
  Stream<UserEntity?> authStateChanges();
}

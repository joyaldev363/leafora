import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Available states in the authentication lifecycle.
enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  unauthenticated,
  error,
}

/// Immutable state container for authentication.
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.pendingPhone,
    this.pendingFullName,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  /// Holds the phone number currently awaiting OTP verification.
  final String? pendingPhone;

  /// Holds the pending full name to attach once OTP is verified.
  final String? pendingFullName;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    String? pendingPhone,
    String? pendingFullName,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingPhone: pendingPhone ?? this.pendingPhone,
      pendingFullName: pendingFullName ?? this.pendingFullName,
    );
  }
}

/// Riverpod StateNotifier coordinating authentication business logic and UI states.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    checkCurrentUser();
  }

  final AuthRepository _repository;

  /// Inspects the current session on startup.
  void checkCurrentUser() {
    final user = _repository.getCurrentUser();
    if (user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
    }
  }

  /// Sends a one-time verification code via SMS to [phone].
  Future<bool> sendOtp({
    required String phone,
    String? fullName,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      pendingPhone: phone,
      pendingFullName: fullName,
    );

    try {
      await _repository.sendOtp(phone);
      state = state.copyWith(
        status: AuthStatus.otpSent,
        pendingPhone: phone,
        pendingFullName: fullName,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Unable to send OTP. Please try again.',
      );
      return false;
    }
  }

  /// Verifies the 6-digit OTP code received by the user.
  Future<bool> verifyOtp({
    required String phone,
    required String token,
    String? fullName,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    try {
      final user = await _repository.verifyOtp(
        phone: phone,
        token: token,
        fullName: fullName ?? state.pendingFullName,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid or expired OTP. Please try again.',
      );
      return false;
    }
  }

  /// Updates profile metadata with [fullName].
  Future<bool> updateProfile(String fullName) async {
    if (state.isLoading) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
    );

    try {
      final updatedUser = await _repository.updateProfile(fullName: fullName);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }

  /// Logs the user out and clears the local session state.
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.signOut();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Resets active error messages.
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

// -----------------------------------------------------------------------------
// Riverpod Providers
// -----------------------------------------------------------------------------

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return const AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

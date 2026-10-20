import 'package:flutter/foundation.dart';

/// Base Failure representation for handling domain-level errors.
@immutable
sealed class Failure {
  const Failure({required this.message, this.code});

  /// User-friendly message explaining the cause of the failure.
  final String message;

  /// Optional machine-readable error code.
  final String? code;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => Object.hash(message, code);

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Represents failure caused by missing internet connectivity or socket issues.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Please check your internet connection and try again.',
    super.code = 'NETWORK_FAILURE',
  });
}

/// Represents failure caused by remote API or server errors.
final class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code = 'SERVER_FAILURE',
    this.statusCode,
  });

  final int? statusCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServerFailure &&
        other.message == message &&
        other.code == code &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode => Object.hash(message, code, statusCode);
}

/// Represents failure caused by local database, cache, or Hive operation failures.
final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Unable to read or save data locally.',
    super.code = 'CACHE_FAILURE',
  });
}

/// Represents input or form validation failures.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_FAILURE',
  });
}

/// Represents failure when configuring or dispatching notifications.
final class NotificationFailure extends Failure {
  const NotificationFailure({
    super.message = 'Failed to schedule or manage reminders.',
    super.code = 'NOTIFICATION_FAILURE',
  });
}

/// Represents unexpected, unmapped, or fallback errors.
final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNKNOWN_FAILURE',
  });
}

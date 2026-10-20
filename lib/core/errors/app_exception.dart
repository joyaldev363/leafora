/// Base class for all domain and infrastructure exceptions in Leafora.
sealed class AppException implements Exception {
  const AppException({required this.message, this.code, this.details});

  /// Human-readable error message explaining what went wrong.
  final String message;

  /// Optional machine-readable error code.
  final String? code;

  /// Optional debug or stack details for logging.
  final Object? details;

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (details != null) {
      buffer.write(' | Details: $details');
    }
    return buffer.toString();
  }
}

/// Thrown when an unexpected error occurs during remote API/server communication.
final class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  final int? statusCode;

  @override
  String toString() {
    return 'ServerException(statusCode: $statusCode, message: $message, code: $code)';
  }
}

/// Thrown when local storage (e.g. Hive) read, write, or initialization fails.
final class CacheException extends AppException {
  const CacheException({required super.message, super.code, super.details});
}

/// Thrown when network transport fails (e.g., no connection, connection timeout, socket error).
final class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection or network request timed out.',
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

/// Thrown when local notification scheduling, permission grant, or cancellation fails.
final class NotificationException extends AppException {
  const NotificationException({
    required super.message,
    super.code = 'NOTIFICATION_ERROR',
    super.details,
  });
}

/// Thrown when input data or parameter validation fails before processing.
final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.details,
  });
}

/// Thrown when authentication or session validation fails.
final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.details,
  });
}

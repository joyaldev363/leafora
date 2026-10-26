import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/app_exception.dart';

/// Foundation service managing the lifecycle and client access for Supabase.
///
/// Project URL and Anon Key are retrieved safely via compile-time environment
/// variables (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) or passed explicitly
/// during initialization. Never expose the service-role key in client code.
class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  bool _isInitialized = false;

  /// Whether Supabase has been initialized.
  bool get isInitialized => _isInitialized;

  /// Returns the active [SupabaseClient].
  ///
  /// Throws [ServerException] if accessed prior to calling [initialize].
  SupabaseClient get client {
    if (!_isInitialized) {
      throw const ServerException(
        message:
            'Supabase has not been initialized. Call SupabaseService.initialize() first.',
        code: 'SUPABASE_NOT_INITIALIZED',
      );
    }
    return Supabase.instance.client;
  }

  /// Explicitly initializes Supabase.
  ///
  /// Safe configuration: reads [url] and [anonKey] from `--dart-define`
  /// environment variables by default.
  ///
  /// Throws [ServerException] if required configuration is missing or
  /// if initialization fails.
  Future<void> initialize({
    String? url,
    String? anonKey,
  }) async {
    if (_isInitialized) {
      debugPrint('SupabaseService: Already initialized, skipping duplicate init.');
      return;
    }

    final effectiveUrl = url ?? const String.fromEnvironment('SUPABASE_URL');
    final effectiveAnonKey =
        anonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (effectiveUrl.trim().isEmpty) {
      throw const ServerException(
        message:
            'Missing Supabase URL. Provide SUPABASE_URL via --dart-define or pass it to initialize().',
        code: 'MISSING_SUPABASE_URL',
      );
    }

    if (effectiveAnonKey.trim().isEmpty) {
      throw const ServerException(
        message:
            'Missing Supabase Anon Key. Provide SUPABASE_ANON_KEY via --dart-define or pass it to initialize().',
        code: 'MISSING_SUPABASE_ANON_KEY',
      );
    }

    try {
      await Supabase.initialize(
        url: effectiveUrl.trim(),
        anonKey: effectiveAnonKey.trim(),
      );
      _isInitialized = true;
      debugPrint('SupabaseService: Initialized successfully.');
    } catch (e, stackTrace) {
      throw ServerException(
        message: 'Failed to initialize Supabase: ${e.toString()}',
        code: 'SUPABASE_INIT_ERROR',
        details: stackTrace.toString(),
      );
    }
  }
}

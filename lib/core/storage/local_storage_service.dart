import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

/// Contract for application local storage operations.
///
/// **Security Notice:**
/// Do **NOT** store secrets, API keys, passwords, or raw authentication tokens
/// in ordinary Hive boxes. Standard Hive boxes are stored unencrypted on disk.
/// Use a platform keychain/keystore abstraction (such as `flutter_secure_storage`)
/// for sensitive authentication credentials.
abstract interface class LocalStorageService {
  /// Initializes the local storage engine and opens pre-configured boxes.
  Future<void> init();

  /// Reads a value associated with [key] in [boxName].
  T? get<T>(String boxName, String key, {T? defaultValue});

  /// Persists a [value] for [key] in [boxName].
  Future<void> put<T>(String boxName, String key, T value);

  /// Removes an entry associated with [key] from [boxName].
  Future<void> delete(String boxName, String key);

  /// Checks whether a [key] exists in [boxName].
  bool containsKey(String boxName, String key);

  /// Returns all stored values in [boxName].
  List<T> getAll<T>(String boxName);

  /// Clears all entries within [boxName].
  Future<void> clearBox(String boxName);

  /// Closes all opened Hive boxes.
  Future<void> close();
}

/// Production implementation of [LocalStorageService] using Hive.
class LocalStorageServiceImpl implements LocalStorageService {
  bool _isInitialized = false;

  /// Explicit setup method to initialize Hive and open core application boxes.
  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Open standard Leafora data boxes
      await Future.wait([
        Hive.openBox<dynamic>(AppConstants.plantsBox),
        Hive.openBox<dynamic>(AppConstants.settingsBox),
        Hive.openBox<dynamic>(AppConstants.userPreferencesBox),
        Hive.openBox<dynamic>(AppConstants.cacheBox),
      ]);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Hive initialization failed: $e');
      throw CacheException(
        message: 'Failed to initialize local Hive storage.',
        details: e,
      );
    }
  }

  Box<dynamic> _getBox(String boxName) {
    if (!_isInitialized) {
      throw const CacheException(
        message: 'LocalStorageService is not initialized. Call init() first.',
      );
    }
    if (!Hive.isBoxOpen(boxName)) {
      throw CacheException(message: 'Box "$boxName" is not currently open.');
    }
    return Hive.box<dynamic>(boxName);
  }

  @override
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    try {
      final box = _getBox(boxName);
      final value = box.get(key, defaultValue: defaultValue);
      if (value == null) return defaultValue;
      return value as T;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read key "$key" from box "$boxName".',
        details: e,
      );
    }
  }

  @override
  Future<void> put<T>(String boxName, String key, T value) async {
    try {
      final box = _getBox(boxName);
      await box.put(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to write key "$key" to box "$boxName".',
        details: e,
      );
    }
  }

  @override
  Future<void> delete(String boxName, String key) async {
    try {
      final box = _getBox(boxName);
      await box.delete(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete key "$key" from box "$boxName".',
        details: e,
      );
    }
  }

  @override
  bool containsKey(String boxName, String key) {
    try {
      final box = _getBox(boxName);
      return box.containsKey(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed checking key "$key" in box "$boxName".',
        details: e,
      );
    }
  }

  @override
  List<T> getAll<T>(String boxName) {
    try {
      final box = _getBox(boxName);
      return box.values.whereType<T>().toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed retrieving values from box "$boxName".',
        details: e,
      );
    }
  }

  @override
  Future<void> clearBox(String boxName) async {
    try {
      final box = _getBox(boxName);
      await box.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear box "$boxName".',
        details: e,
      );
    }
  }

  @override
  Future<void> close() async {
    try {
      await Hive.close();
      _isInitialized = false;
    } catch (e) {
      throw CacheException(
        message: 'Failed to close local storage boxes.',
        details: e,
      );
    }
  }
}

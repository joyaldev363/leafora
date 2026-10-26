import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import 'supabase_service.dart';

/// Reusable service for Supabase Storage image operations.
///
/// Supports upload, removal, public URL resolution, and signed URL generation
/// for private buckets.
class ImageStorageService {
  ImageStorageService({
    this.client,
    this.defaultBucket = AppConstants.defaultStorageBucket,
  });

  final SupabaseClient? client;
  final String defaultBucket;

  SupabaseClient get _effectiveClient =>
      client ?? SupabaseService.instance.client;

  StorageFileApi _getBucketApi(String? bucket) {
    final bucketName = bucket ?? defaultBucket;
    if (bucketName.trim().isEmpty) {
      throw const ValidationException(
        message: 'Storage bucket name must not be empty.',
      );
    }
    return _effectiveClient.storage.from(bucketName);
  }

  /// Uploads image bytes to a specified storage bucket and path.
  ///
  /// Returns the storage file path upon success.
  /// Throws [ValidationException] or [ServerException] on failure.
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String path,
    String? bucket,
    String? contentType,
    bool upsert = false,
  }) async {
    final cleanPath = path.trim();
    if (cleanPath.isEmpty) {
      throw const ValidationException(
        message: 'Storage upload path must not be empty.',
      );
    }
    if (bytes.isEmpty) {
      throw const ValidationException(
        message: 'Image bytes cannot be empty.',
      );
    }

    try {
      final bucketApi = _getBucketApi(bucket);
      await bucketApi.uploadBinary(
        cleanPath,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType ?? 'image/jpeg',
          upsert: upsert,
        ),
      );
      return cleanPath;
    } on StorageException catch (e) {
      throw ServerException(
        message: 'Storage error during upload: ${e.message}',
        code: e.statusCode,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } catch (e, stack) {
      throw ServerException(
        message: 'Failed to upload image: ${e.toString()}',
        code: 'STORAGE_UPLOAD_ERROR',
        details: stack.toString(),
      );
    }
  }

  /// Uploads a local [File] image to a specified storage bucket and path.
  ///
  /// Returns the storage file path upon success.
  /// Throws [ValidationException] or [ServerException] on failure.
  Future<String> uploadFile({
    required File file,
    required String path,
    String? bucket,
    String? contentType,
    bool upsert = false,
  }) async {
    if (!await file.exists()) {
      throw ValidationException(
        message: 'File not found at: ${file.path}',
      );
    }
    final bytes = await file.readAsBytes();
    return uploadBytes(
      bytes: bytes,
      path: path,
      bucket: bucket,
      contentType: contentType,
      upsert: upsert,
    );
  }

  /// Returns the permanent public URL for a file in a public bucket.
  String getPublicUrl({
    required String path,
    String? bucket,
  }) {
    final cleanPath = path.trim();
    if (cleanPath.isEmpty) {
      throw const ValidationException(
        message: 'Path cannot be empty when retrieving public URL.',
      );
    }
    final bucketApi = _getBucketApi(bucket);
    return bucketApi.getPublicUrl(cleanPath);
  }

  /// Creates a temporary signed URL for an asset in a private bucket.
  ///
  /// [expiresInSeconds] defaults to 3600 (1 hour).
  Future<String> createSignedUrl({
    required String path,
    String? bucket,
    int expiresInSeconds = 3600,
  }) async {
    final cleanPath = path.trim();
    if (cleanPath.isEmpty) {
      throw const ValidationException(
        message: 'Path cannot be empty when generating signed URL.',
      );
    }
    try {
      final bucketApi = _getBucketApi(bucket);
      return await bucketApi.createSignedUrl(cleanPath, expiresInSeconds);
    } on StorageException catch (e) {
      throw ServerException(
        message: 'Storage error generating signed URL: ${e.message}',
        code: e.statusCode,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } catch (e, stack) {
      throw ServerException(
        message: 'Failed to generate signed URL: ${e.toString()}',
        code: 'STORAGE_SIGNED_URL_ERROR',
        details: stack.toString(),
      );
    }
  }

  /// Deletes an image file from the specified bucket.
  Future<void> deleteImage({
    required String path,
    String? bucket,
  }) async {
    final cleanPath = path.trim();
    if (cleanPath.isEmpty) {
      throw const ValidationException(
        message: 'Path cannot be empty when deleting image.',
      );
    }
    try {
      final bucketApi = _getBucketApi(bucket);
      await bucketApi.remove([cleanPath]);
    } on StorageException catch (e) {
      throw ServerException(
        message: 'Storage error deleting image: ${e.message}',
        code: e.statusCode,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } catch (e, stack) {
      throw ServerException(
        message: 'Failed to delete image: ${e.toString()}',
        code: 'STORAGE_DELETE_ERROR',
        details: stack.toString(),
      );
    }
  }
}

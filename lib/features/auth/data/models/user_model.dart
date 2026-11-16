import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

/// Data layer representation of [UserEntity] with Supabase serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    super.fullName,
    super.createdAt,
    super.updatedAt,
  });

  /// Instantiates a [UserModel] from a Supabase [User] instance.
  factory UserModel.fromSupabaseUser(
    User user, [
    Map<String, dynamic>? profileData,
  ]) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final resolvedFullName =
        profileData?['full_name'] as String? ?? metadata['full_name'] as String?;

    DateTime? parsedCreatedAt;
    try {
      if (user.createdAt.isNotEmpty) {
        parsedCreatedAt = DateTime.parse(user.createdAt);
      }
    } catch (_) {}

    DateTime? parsedUpdatedAt;
    try {
      if (user.updatedAt != null && user.updatedAt!.isNotEmpty) {
        parsedUpdatedAt = DateTime.parse(user.updatedAt!);
      }
    } catch (_) {}

    return UserModel(
      id: user.id,
      phone: user.phone ?? '',
      fullName: resolvedFullName,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  /// Instantiates a [UserModel] from a JSON map (e.g. from local cache or REST response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

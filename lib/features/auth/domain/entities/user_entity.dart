import 'package:flutter/foundation.dart';

/// Core domain entity representing an authenticated Leafora user.
@immutable
class UserEntity {
  const UserEntity({
    required this.id,
    required this.phone,
    this.fullName,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier of the user in Supabase.
  final String id;

  /// Verified phone number in international format (e.g. +919876543210).
  final String phone;

  /// User's display name or full name.
  final String? fullName;

  /// Timestamp when the account was registered.
  final DateTime? createdAt;

  /// Timestamp when the profile was last modified.
  final DateTime? updatedAt;

  /// Creates a copy of this entity with the given fields replaced.
  UserEntity copyWith({
    String? id,
    String? phone,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.phone == phone &&
        other.fullName == fullName &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, phone, fullName, createdAt, updatedAt);

  @override
  String toString() {
    return 'UserEntity(id: $id, phone: $phone, fullName: $fullName)';
  }
}

import 'package:flutter/foundation.dart';

/// Entity representing a discovery filter category.
@immutable
class DiscoverCategoryEntity {
  const DiscoverCategoryEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final String? description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoverCategoryEntity &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}

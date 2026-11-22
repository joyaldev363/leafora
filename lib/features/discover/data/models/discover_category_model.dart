import '../../domain/entities/discover_category_entity.dart';

/// Data model representing a discovery category with JSON serialization.
class DiscoverCategoryModel extends DiscoverCategoryEntity {
  const DiscoverCategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.description,
  });

  factory DiscoverCategoryModel.fromJson(Map<String, dynamic> json) {
    return DiscoverCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'description': description,
    };
  }

  factory DiscoverCategoryModel.fromEntity(DiscoverCategoryEntity entity) {
    return DiscoverCategoryModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      description: entity.description,
    );
  }
}

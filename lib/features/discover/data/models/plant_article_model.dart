import '../../domain/entities/plant_article_entity.dart';

/// Data model representing a plant care article with JSON serialization.
class PlantArticleModel extends PlantArticleEntity {
  const PlantArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.coverImageUrl,
    required super.category,
    required super.content,
    required super.readingTime,
    super.createdAt,
    super.isBookmarked,
  });

  factory PlantArticleModel.fromJson(Map<String, dynamic> json) {
    return PlantArticleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String? ??
          json['coverImageUrl'] as String? ??
          '',
      category: json['category'] as String? ?? 'General',
      content: json['content'] as String? ?? '',
      readingTime: json['reading_time'] as String? ??
          json['readingTime'] as String? ??
          '5 min read',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'category': category,
      'content': content,
      'reading_time': readingTime,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory PlantArticleModel.fromEntity(PlantArticleEntity entity) {
    return PlantArticleModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      coverImageUrl: entity.coverImageUrl,
      category: entity.category,
      content: entity.content,
      readingTime: entity.readingTime,
      createdAt: entity.createdAt,
      isBookmarked: entity.isBookmarked,
    );
  }
}

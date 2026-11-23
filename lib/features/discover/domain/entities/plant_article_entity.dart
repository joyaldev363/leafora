import 'package:flutter/foundation.dart';

/// Entity representing an educational plant care article.
@immutable
class PlantArticleEntity {
  const PlantArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.category,
    required this.content,
    required this.readingTime,
    this.createdAt,
    this.isBookmarked = false,
  });

  final String id;
  final String title;
  final String description;
  final String coverImageUrl;
  final String category;
  final String content;
  final String readingTime;
  final DateTime? createdAt;
  final bool isBookmarked;

  PlantArticleEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImageUrl,
    String? category,
    String? content,
    String? readingTime,
    DateTime? createdAt,
    bool? isBookmarked,
  }) {
    return PlantArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      category: category ?? this.category,
      content: content ?? this.content,
      readingTime: readingTime ?? this.readingTime,
      createdAt: createdAt ?? this.createdAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantArticleEntity &&
        other.id == id &&
        other.title == title &&
        other.isBookmarked == isBookmarked;
  }

  @override
  int get hashCode => Object.hash(id, title, isBookmarked);
}

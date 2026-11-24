import 'package:flutter/foundation.dart';

/// Entity representing a comprehensive botanical care guide for a plant species.
@immutable
class PlantGuideEntity {
  const PlantGuideEntity({
    required this.id,
    required this.plantName,
    this.scientificName,
    required this.imageUrl,
    required this.description,
    this.category = 'Indoor Plants',
    this.difficulty = 'Easy',
    required this.watering,
    required this.sunlight,
    required this.soil,
    required this.fertilizer,
    required this.careInstructions,
    this.isBookmarked = false,
  });

  final String id;
  final String plantName;
  final String? scientificName;
  final String imageUrl;
  final String description;
  final String category;
  final String difficulty;
  final String watering;
  final String sunlight;
  final String soil;
  final String fertilizer;
  final String careInstructions;
  final bool isBookmarked;

  PlantGuideEntity copyWith({
    String? id,
    String? plantName,
    String? scientificName,
    String? imageUrl,
    String? description,
    String? category,
    String? difficulty,
    String? watering,
    String? sunlight,
    String? soil,
    String? fertilizer,
    String? careInstructions,
    bool? isBookmarked,
  }) {
    return PlantGuideEntity(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      scientificName: scientificName ?? this.scientificName,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      watering: watering ?? this.watering,
      sunlight: sunlight ?? this.sunlight,
      soil: soil ?? this.soil,
      fertilizer: fertilizer ?? this.fertilizer,
      careInstructions: careInstructions ?? this.careInstructions,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantGuideEntity &&
        other.id == id &&
        other.plantName == plantName &&
        other.isBookmarked == isBookmarked;
  }

  @override
  int get hashCode => Object.hash(id, plantName, isBookmarked);
}

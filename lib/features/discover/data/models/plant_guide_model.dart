import '../../domain/entities/plant_guide_entity.dart';

/// Data model representing a botanical plant care guide with JSON serialization.
class PlantGuideModel extends PlantGuideEntity {
  const PlantGuideModel({
    required super.id,
    required super.plantName,
    super.scientificName,
    required super.imageUrl,
    required super.description,
    super.category,
    super.difficulty,
    required super.watering,
    required super.sunlight,
    required super.soil,
    required super.fertilizer,
    required super.careInstructions,
    super.isBookmarked,
  });

  factory PlantGuideModel.fromJson(Map<String, dynamic> json) {
    return PlantGuideModel(
      id: json['id'] as String? ?? '',
      plantName: json['plant_name'] as String? ??
          json['plantName'] as String? ??
          '',
      scientificName: json['scientific_name'] as String? ??
          json['scientificName'] as String?,
      imageUrl: json['image_url'] as String? ??
          json['imageUrl'] as String? ??
          '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Indoor Plants',
      difficulty: json['difficulty'] as String? ?? 'Easy',
      watering: json['watering'] as String? ?? 'Every 7 days',
      sunlight: json['sunlight'] as String? ?? 'Bright, indirect light',
      soil: json['soil'] as String? ?? 'Well-draining potting mix',
      fertilizer: json['fertilizer'] as String? ?? 'Monthly during spring/summer',
      careInstructions: json['care_instructions'] as String? ??
          json['careInstructions'] as String? ??
          '',
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_name': plantName,
      'scientific_name': scientificName,
      'image_url': imageUrl,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'watering': watering,
      'sunlight': sunlight,
      'soil': soil,
      'fertilizer': fertilizer,
      'care_instructions': careInstructions,
    };
  }

  factory PlantGuideModel.fromEntity(PlantGuideEntity entity) {
    return PlantGuideModel(
      id: entity.id,
      plantName: entity.plantName,
      scientificName: entity.scientificName,
      imageUrl: entity.imageUrl,
      description: entity.description,
      category: entity.category,
      difficulty: entity.difficulty,
      watering: entity.watering,
      sunlight: entity.sunlight,
      soil: entity.soil,
      fertilizer: entity.fertilizer,
      careInstructions: entity.careInstructions,
      isBookmarked: entity.isBookmarked,
    );
  }
}

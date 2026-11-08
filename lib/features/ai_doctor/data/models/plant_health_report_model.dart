import '../../domain/entities/plant_health_report_entity.dart';

/// Data model representing a plant health report with JSON serialization.
class PlantHealthReportModel extends PlantHealthReportEntity {
  const PlantHealthReportModel({
    required super.id,
    required super.plantName,
    super.scientificName,
    super.confidence = 92,
    required super.healthStatus,
    required super.severity,
    super.healthScore = 75,
    required super.symptoms,
    required super.possibleCauses,
    required super.treatmentRecommendations,
    required super.imagePath,
    required super.analyzedAt,
  });

  factory PlantHealthReportModel.fromJson(Map<String, dynamic> json) {
    HealthSeverity severity;
    final sevStr = (json['severity'] as String? ?? 'mild').toLowerCase();
    switch (sevStr) {
      case 'none':
      case 'optimal':
        severity = HealthSeverity.none;
        break;
      case 'moderate':
        severity = HealthSeverity.moderate;
        break;
      case 'severe':
      case 'critical':
        severity = HealthSeverity.severe;
        break;
      case 'mild':
      default:
        severity = HealthSeverity.mild;
        break;
    }

    return PlantHealthReportModel(
      id: json['id'] as String? ?? 'report_${DateTime.now().millisecondsSinceEpoch}',
      plantName: json['plant_name'] as String? ??
          json['plantName'] as String? ??
          'Unknown Plant',
      scientificName: json['scientific_name'] as String? ??
          json['scientificName'] as String?,
      confidence: (json['confidence'] as num?)?.toInt() ?? 92,
      healthStatus: json['health_status'] as String? ??
          json['healthStatus'] as String? ??
          'Needs Attention',
      severity: severity,
      healthScore: (json['health_score'] as num?)?.toInt() ??
          (json['healthScore'] as num?)?.toInt() ??
          75,
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      possibleCauses: (json['possible_causes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      treatmentRecommendations: (json['treatment_recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      imagePath: json['image_path'] as String? ??
          json['imagePath'] as String? ??
          '',
      analyzedAt: json['analyzed_at'] != null
          ? DateTime.tryParse(json['analyzed_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_name': plantName,
      'scientific_name': scientificName,
      'confidence': confidence,
      'health_status': healthStatus,
      'severity': severity.name,
      'health_score': healthScore,
      'symptoms': symptoms,
      'possible_causes': possibleCauses,
      'treatment_recommendations': treatmentRecommendations,
      'image_path': imagePath,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  factory PlantHealthReportModel.fromEntity(PlantHealthReportEntity entity) {
    return PlantHealthReportModel(
      id: entity.id,
      plantName: entity.plantName,
      scientificName: entity.scientificName,
      confidence: entity.confidence,
      healthStatus: entity.healthStatus,
      severity: entity.severity,
      healthScore: entity.healthScore,
      symptoms: entity.symptoms,
      possibleCauses: entity.possibleCauses,
      treatmentRecommendations: entity.treatmentRecommendations,
      imagePath: entity.imagePath,
      analyzedAt: entity.analyzedAt,
    );
  }
}

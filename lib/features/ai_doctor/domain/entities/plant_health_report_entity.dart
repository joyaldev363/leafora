import 'package:flutter/foundation.dart';

/// Health condition severity level.
enum HealthSeverity {
  none,
  mild,
  moderate,
  severe;

  String get label {
    switch (this) {
      case HealthSeverity.none:
        return 'Optimal';
      case HealthSeverity.mild:
        return 'Mild';
      case HealthSeverity.moderate:
        return 'Moderate';
      case HealthSeverity.severe:
        return 'Severe';
    }
  }
}

/// Core domain entity representing the comprehensive botanical health report.
@immutable
class PlantHealthReportEntity {
  const PlantHealthReportEntity({
    required this.id,
    required this.plantName,
    this.scientificName,
    this.confidence = 92,
    required this.healthStatus,
    required this.severity,
    this.healthScore = 75,
    required this.symptoms,
    required this.possibleCauses,
    required this.treatmentRecommendations,
    required this.imagePath,
    required this.analyzedAt,
  });

  /// Unique identifier of this health report.
  final String id;

  /// Identified botanical name of the specimen.
  final String plantName;

  /// Optional Latin scientific nomenclature.
  final String? scientificName;

  /// Confidence percentage of botanical classification (e.g. 92%).
  final int confidence;

  /// High-level diagnosis status (e.g. 'Needs Attention', 'Healthy', 'Action Required').
  final String healthStatus;

  /// Diagnosis severity rating.
  final HealthSeverity severity;

  /// Overall health score between 0 and 100.
  final int healthScore;

  /// Observable signs and visible symptoms.
  final List<String> symptoms;

  /// Hypothesized environmental or care-related causes (labeled as possibilities).
  final List<String> possibleCauses;

  /// Actionable treatment and recovery recommendations.
  final List<String> treatmentRecommendations;

  /// File path or remote URL of the evaluated plant photograph.
  final String imagePath;

  /// Timestamp when the diagnostic analysis was conducted.
  final DateTime analyzedAt;

  PlantHealthReportEntity copyWith({
    String? id,
    String? plantName,
    String? scientificName,
    int? confidence,
    String? healthStatus,
    HealthSeverity? severity,
    int? healthScore,
    List<String>? symptoms,
    List<String>? possibleCauses,
    List<String>? treatmentRecommendations,
    String? imagePath,
    DateTime? analyzedAt,
  }) {
    return PlantHealthReportEntity(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      scientificName: scientificName ?? this.scientificName,
      confidence: confidence ?? this.confidence,
      healthStatus: healthStatus ?? this.healthStatus,
      severity: severity ?? this.severity,
      healthScore: healthScore ?? this.healthScore,
      symptoms: symptoms ?? this.symptoms,
      possibleCauses: possibleCauses ?? this.possibleCauses,
      treatmentRecommendations:
          treatmentRecommendations ?? this.treatmentRecommendations,
      imagePath: imagePath ?? this.imagePath,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantHealthReportEntity &&
        other.id == id &&
        other.plantName == plantName &&
        other.scientificName == scientificName &&
        other.confidence == confidence &&
        other.healthStatus == healthStatus &&
        other.severity == severity &&
        other.healthScore == healthScore &&
        other.imagePath == imagePath &&
        listEquals(other.symptoms, symptoms) &&
        listEquals(other.possibleCauses, possibleCauses) &&
        listEquals(other.treatmentRecommendations, treatmentRecommendations);
  }

  @override
  int get hashCode => Object.hash(
        id,
        plantName,
        scientificName,
        confidence,
        healthStatus,
        severity,
        healthScore,
        imagePath,
        Object.hashAll(symptoms),
        Object.hashAll(possibleCauses),
        Object.hashAll(treatmentRecommendations),
      );
}

import '../entities/plant_health_report_entity.dart';

/// Contract defining AI botanical diagnosis and report management operations.
abstract interface class AiDoctorRepository {
  /// Evaluates an image of a plant to generate a botanical health report.
  Future<PlantHealthReportEntity> analyzePlant({required String imagePath});

  /// Persists a diagnostic health report.
  Future<void> saveHealthReport(PlantHealthReportEntity report);

  /// Retrieves previously saved health reports.
  Future<List<PlantHealthReportEntity>> getSavedHealthReports();
}

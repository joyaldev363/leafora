import '../entities/plant_health_report_entity.dart';
import '../repositories/ai_doctor_repository.dart';

/// Use case that analyzes a plant photo to diagnose botanical health.
class AnalyzePlantUseCase {
  const AnalyzePlantUseCase(this._repository);

  final AiDoctorRepository _repository;

  Future<PlantHealthReportEntity> call({required String imagePath}) {
    return _repository.analyzePlant(imagePath: imagePath);
  }
}

import '../entities/plant_health_report_entity.dart';
import '../repositories/ai_doctor_repository.dart';

/// Use case that persists a generated plant health report.
class SaveHealthReportUseCase {
  const SaveHealthReportUseCase(this._repository);

  final AiDoctorRepository _repository;

  Future<void> call(PlantHealthReportEntity report) {
    return _repository.saveHealthReport(report);
  }
}

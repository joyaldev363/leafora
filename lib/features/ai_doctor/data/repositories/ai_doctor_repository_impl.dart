import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/plant_health_report_entity.dart';
import '../../domain/repositories/ai_doctor_repository.dart';
import '../datasources/ai_doctor_remote_datasource.dart';
import '../models/plant_health_report_model.dart';

/// Implementation of [AiDoctorRepository] bridging remote data sources with domain logic.
class AiDoctorRepositoryImpl implements AiDoctorRepository {
  const AiDoctorRepositoryImpl({
    required this.remoteDataSource,
  });

  final AiDoctorRemoteDataSource remoteDataSource;

  @override
  Future<PlantHealthReportEntity> analyzePlant({
    required String imagePath,
  }) async {
    try {
      return await remoteDataSource.analyzePlant(imagePath: imagePath);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to complete plant analysis: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveHealthReport(PlantHealthReportEntity report) async {
    try {
      final model = PlantHealthReportModel.fromEntity(report);
      await remoteDataSource.saveHealthReport(model);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to save health report: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PlantHealthReportEntity>> getSavedHealthReports() async {
    try {
      return await remoteDataSource.getSavedHealthReports();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to retrieve saved health reports: ${e.toString()}',
      );
    }
  }
}

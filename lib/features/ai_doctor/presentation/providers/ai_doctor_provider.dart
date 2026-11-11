import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/ai_doctor_remote_datasource.dart';
import '../../data/repositories/ai_doctor_repository_impl.dart';
import '../../domain/entities/plant_health_report_entity.dart';
import '../../domain/repositories/ai_doctor_repository.dart';
import '../../domain/usecases/analyze_plant_usecase.dart';
import '../../domain/usecases/save_health_report_usecase.dart';

/// Dependency injection providers for AI Doctor Clean Architecture
final aiDoctorRemoteDataSourceProvider =
    Provider<AiDoctorRemoteDataSource>((ref) {
  return AiDoctorRemoteDataSourceImpl();
});

final aiDoctorRepositoryProvider = Provider<AiDoctorRepository>((ref) {
  final remoteDataSource = ref.watch(aiDoctorRemoteDataSourceProvider);
  return AiDoctorRepositoryImpl(remoteDataSource: remoteDataSource);
});

final analyzePlantUseCaseProvider = Provider<AnalyzePlantUseCase>((ref) {
  final repository = ref.watch(aiDoctorRepositoryProvider);
  return AnalyzePlantUseCase(repository);
});

final saveHealthReportUseCaseProvider = Provider<SaveHealthReportUseCase>((ref) {
  final repository = ref.watch(aiDoctorRepositoryProvider);
  return SaveHealthReportUseCase(repository);
});

/// State representation of the AI Doctor diagnosis flow.
@immutable
class AiDoctorState {
  const AiDoctorState({
    this.selectedImagePath,
    this.isPickingImage = false,
    this.isAnalyzing = false,
    this.analysisStage = '',
    this.report,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
  });

  final String? selectedImagePath;
  final bool isPickingImage;
  final bool isAnalyzing;
  final String analysisStage;
  final PlantHealthReportEntity? report;
  final bool isSaving;
  final bool isSaved;
  final String? errorMessage;

  bool get hasImage =>
      selectedImagePath != null && selectedImagePath!.trim().isNotEmpty;

  AiDoctorState copyWith({
    String? selectedImagePath,
    bool? clearSelectedImage,
    bool? isPickingImage,
    bool? isAnalyzing,
    String? analysisStage,
    PlantHealthReportEntity? report,
    bool? clearReport,
    bool? isSaving,
    bool? isSaved,
    String? errorMessage,
    bool? clearError,
  }) {
    return AiDoctorState(
      selectedImagePath: clearSelectedImage == true
          ? null
          : (selectedImagePath ?? this.selectedImagePath),
      isPickingImage: isPickingImage ?? this.isPickingImage,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      analysisStage: analysisStage ?? this.analysisStage,
      report: clearReport == true ? null : (report ?? this.report),
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: clearError == true ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// State notifier managing image picking, diagnostic scanning, and report saving.
class AiDoctorNotifier extends StateNotifier<AiDoctorState> {
  AiDoctorNotifier({
    required this.analyzeUseCase,
    required this.saveUseCase,
    ImagePicker? picker,
  })  : _picker = picker ?? ImagePicker(),
        super(const AiDoctorState());

  final AnalyzePlantUseCase analyzeUseCase;
  final SaveHealthReportUseCase saveUseCase;
  final ImagePicker _picker;

  /// Captures a fresh plant photo via device camera.
  Future<bool> capturePlantImage() async {
    return _pickFromSource(ImageSource.camera);
  }

  /// Selects an existing photo from the user's gallery.
  Future<bool> selectImageFromGallery() async {
    return _pickFromSource(ImageSource.gallery);
  }

  /// Replaces the currently selected image by reopening picker.
  Future<bool> replaceSelectedImage(ImageSource source) async {
    return _pickFromSource(source);
  }

  /// Clears the currently selected image.
  void clearSelectedImage() {
    state = state.copyWith(clearSelectedImage: true, clearReport: true, clearError: true);
  }

  Future<bool> _pickFromSource(ImageSource source) async {
    state = state.copyWith(isPickingImage: true, clearError: true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );

      if (picked != null) {
        state = state.copyWith(
          selectedImagePath: picked.path,
          isPickingImage: false,
          clearError: true,
        );
        return true;
      }
      state = state.copyWith(isPickingImage: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isPickingImage: false,
        errorMessage: 'Unable to access ${source.name}: ${e.toString()}',
      );
      return false;
    }
  }

  /// Initiates the multi-stage AI diagnostic analysis pipeline.
  Future<bool> analyzePlant() async {
    final imagePath = state.selectedImagePath;
    if (imagePath == null || imagePath.isEmpty) {
      state = state.copyWith(errorMessage: 'Please select a plant photo first.');
      return false;
    }

    if (state.isAnalyzing) return false;

    state = state.copyWith(
      isAnalyzing: true,
      analysisStage: 'Uploading photo to diagnostic engine...',
      clearError: true,
      clearReport: true,
    );

    try {
      // Stage 1
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return false;
      state = state.copyWith(analysisStage: 'Identifying plant species & morphology...');

      // Stage 2
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return false;
      state = state.copyWith(analysisStage: 'Scanning leaf spots, color & visible symptoms...');

      // Stage 3: Actual use case execution
      final result = await analyzeUseCase(imagePath: imagePath);

      if (!mounted) return false;
      state = state.copyWith(
        isAnalyzing: false,
        analysisStage: 'Report ready!',
        report: result,
        isSaved: false,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isAnalyzing: false,
        analysisStage: '',
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Retries the analysis with the currently selected photo.
  Future<bool> retryAnalysis() async {
    return analyzePlant();
  }

  /// Saves the current report to Supabase / local storage.
  Future<bool> saveHealthReport() async {
    final report = state.report;
    if (report == null) return false;

    if (state.isSaving || state.isSaved) return true;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await saveUseCase(report);
      if (!mounted) return false;
      state = state.copyWith(isSaving: false, isSaved: true);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save health report: ${e.toString()}',
      );
      return false;
    }
  }

  /// Resets state back to the scanner screen.
  void resetAnalysis() {
    state = const AiDoctorState();
  }
}

final aiDoctorNotifierProvider =
    StateNotifierProvider<AiDoctorNotifier, AiDoctorState>((ref) {
  final analyzeUseCase = ref.watch(analyzePlantUseCaseProvider);
  final saveUseCase = ref.watch(saveHealthReportUseCaseProvider);
  return AiDoctorNotifier(
    analyzeUseCase: analyzeUseCase,
    saveUseCase: saveUseCase,
  );
});

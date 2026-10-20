/// Centralized asset paths for Leafora.
///
/// NOTE: The asset directories are registered in `pubspec.yaml`.
/// Assets marked as [Planned Asset] indicate expected file placements
/// that must exist on disk in the respective folder before runtime usage.
abstract final class AssetPaths {
  // Base Directories
  static const String _imagesBase = 'assets/images';
  static const String _iconsBase = 'assets/icons';
  static const String _animationsBase = 'assets/animations';

  // ---------------------------------------------------------------------------
  // Logo & Branding
  // ---------------------------------------------------------------------------
  /// [Planned Asset] App primary logo mark.
  /// Expected path: assets/images/logo/app_logo.png
  static const String logo = '$_imagesBase/logo/app_logo.png';

  /// [Planned Asset] Horizontal logo with wordmark.
  /// Expected path: assets/images/logo/app_logo_wordmark.png
  static const String logoWordmark = '$_imagesBase/logo/app_logo_wordmark.png';

  // ---------------------------------------------------------------------------
  // Onboarding Illustrations
  // ---------------------------------------------------------------------------
  /// [Planned Asset] Illustration for onboarding screen 1 (Plant Discovery).
  static const String onboarding1 = '$_imagesBase/onboarding/onboarding_1.png';

  /// [Planned Asset] Illustration for onboarding screen 2 (Care Schedule).
  static const String onboarding2 = '$_imagesBase/onboarding/onboarding_2.png';

  /// [Planned Asset] Illustration for onboarding screen 3 (AI Diagnosis).
  static const String onboarding3 = '$_imagesBase/onboarding/onboarding_3.png';

  // ---------------------------------------------------------------------------
  // Plant Images & Placeholders
  // ---------------------------------------------------------------------------
  /// [Planned Asset] Default placeholder displayed when plant image is missing or loading.
  static const String plantPlaceholder =
      '$_imagesBase/plants/plant_placeholder.png';

  /// [Planned Asset] Default hero plant image.
  static const String defaultPlantHero =
      '$_imagesBase/plants/default_plant_hero.png';

  // ---------------------------------------------------------------------------
  // Icons (SVG or PNG)
  // ---------------------------------------------------------------------------
  /// [Planned Asset] Custom watering can icon.
  static const String wateringCanIcon = '$_iconsBase/ic_watering_can.png';

  /// [Planned Asset] Custom leaf/plant care icon.
  static const String plantCareIcon = '$_iconsBase/ic_plant_care.png';

  // ---------------------------------------------------------------------------
  // Lottie Animations
  // ---------------------------------------------------------------------------
  /// [Planned Asset] Plant growth loading/success animation.
  static const String plantGrowthAnimation =
      '$_animationsBase/plant_growth.json';
}

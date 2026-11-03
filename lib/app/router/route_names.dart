abstract final class RouteNames {
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String signup = '/signup';
  static const String editProfile = '/edit-profile';

  // Main Bottom Navigation Destinations
  static const String home = '/home';
  static const String myPlants = '/my-plants';
  static const String aiDoctor = '/ai-doctor';
  static const String aiDoctorAnalyze = '/ai-doctor/analyze';
  static const String aiDoctorReport = '/ai-doctor/report';
  static const String discover = '/discover';
  static const String profile = '/profile';

  // Plant Management Workflow Routes
  static const String addPlantPhoto = '/add-plant/photo';
  static const String addPlantIdentify = '/add-plant/identify';
  static const String addPlantDetails = '/add-plant/details';
  static const String plantDetails = '/plant-details/:plantId';

  /// Helper generating route path for a specific plant.
  static String plantDetailsPath(String plantId) => '/plant-details/$plantId';

  // Discover Module Routes
  static const String discoverArticle = '/discover/article/:articleId';
  static const String discoverPlantGuide = '/discover/plant/:plantId';
  static const String discoverSaved = '/discover/saved';

  /// Helpers generating discover route paths
  static String discoverArticlePath(String articleId) =>
      '/discover/article/$articleId';
  static String discoverPlantGuidePath(String plantId) =>
      '/discover/plant/$plantId';

  // Profile & Settings Routes
  static const String profileEdit = '/profile/edit';
  static const String profileNotifications = '/profile/notifications';
  static const String profilePlantPreferences = '/profile/plant-preferences';
  static const String profileHelp = '/profile/help';
  static const String profilePrivacy = '/profile/privacy';
}

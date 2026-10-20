/// Application-wide constants and configuration values for Leafora.
abstract final class AppConstants {
  // Application Information
  static const String appName = 'Leafora';
  static const String appTagline = 'Your mindful plant companion';
  static const String appVersion = '1.0.0';

  // Network & Timeout Configurations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Local Storage Box Names (Hive)
  static const String plantsBox = 'leafora_plants_box';
  static const String settingsBox = 'leafora_settings_box';
  static const String userPreferencesBox = 'leafora_user_preferences_box';
  static const String cacheBox = 'leafora_cache_box';

  // Notification Channels & Identifiers
  static const String wateringChannelId = 'leafora_watering_channel';
  static const String wateringChannelName = 'Plant Watering Reminders';
  static const String wateringChannelDescription =
      'Notifications reminding you to hydrate and water your plants.';

  static const String fertilizingChannelId = 'leafora_fertilizing_channel';
  static const String fertilizingChannelName = 'Plant Fertilizing Reminders';
  static const String fertilizingChannelDescription =
      'Notifications reminding you when plants need fertilizing nutrients.';

  static const String generalChannelId = 'leafora_general_channel';
  static const String generalChannelName = 'General Reminders';
  static const String generalChannelDescription =
      'General care tips, alerts, and system updates for Leafora.';

  // Default Care Configuration
  static const int defaultWateringIntervalDays = 7;
  static const int defaultFertilizingIntervalDays = 30;
}

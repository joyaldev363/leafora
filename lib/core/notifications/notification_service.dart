import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

/// Service managing local push notifications and plant care reminders.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  /// Returns whether the notification service has completed initialization.
  bool get isInitialized => _isInitialized;

  /// Initializes the notification plugin and local timezone database.
  Future<void> initialize({
    void Function(NotificationResponse response)? onNotificationTapped,
  }) async {
    if (_isInitialized) return;

    try {
      // 1. Initialize timezone database for accurate scheduled reminders
      tz.initializeTimeZones();

      // 2. Platform initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      final initialized = await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTapped,
      );

      _isInitialized = initialized ?? false;
    } catch (e) {
      debugPrint('NotificationService initialization failed: $e');
      throw NotificationException(
        message: 'Failed to initialize notification service.',
        details: e,
      );
    }
  }

  /// Explicitly requests notification permissions on Android (API 33+) and iOS.
  Future<bool> requestPermissions() async {
    try {
      bool? granted = false;

      // Android 13+ (API 33+) POST_NOTIFICATIONS permission
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        granted = await androidImplementation.requestNotificationsPermission();
      }

      // iOS / Darwin permission request
      final iosImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImplementation != null) {
        granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      return granted ?? false;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Schedules a one-time reminder at a specific future [scheduledDate].
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? channelId,
    String? channelName,
    String? channelDescription,
    String? payload,
  }) async {
    _ensureInitialized();

    if (scheduledDate.isBefore(DateTime.now())) {
      throw const NotificationException(
        message: 'Cannot schedule a reminder in the past.',
      );
    }

    try {
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId ?? AppConstants.generalChannelId,
          channelName ?? AppConstants.generalChannelName,
          channelDescription:
              channelDescription ?? AppConstants.generalChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      throw NotificationException(
        message: 'Failed to schedule notification #$id.',
        details: e,
      );
    }
  }

  /// Convenience method for scheduling a future watering reminder for a specific plant.
  Future<void> schedulePlantWateringReminder({
    required int plantId,
    required String plantName,
    required DateTime scheduledDate,
  }) async {
    await scheduleReminder(
      id: plantId,
      title: 'Time to water $plantName 💧',
      body: 'Keep $plantName happy and healthy with fresh water today.',
      scheduledDate: scheduledDate,
      channelId: AppConstants.wateringChannelId,
      channelName: AppConstants.wateringChannelName,
      channelDescription: AppConstants.wateringChannelDescription,
      payload: 'watering:$plantId',
    );
  }

  /// Convenience method for scheduling a future fertilizing reminder for a specific plant.
  Future<void> schedulePlantFertilizingReminder({
    required int plantId,
    required String plantName,
    required DateTime scheduledDate,
  }) async {
    // Unique ID offset for fertilizing reminders to avoid colliding with watering ID
    final notificationId = plantId + 100000;
    await scheduleReminder(
      id: notificationId,
      title: 'Nourish $plantName 🌱',
      body: '$plantName is due for plant food and nutrients today.',
      scheduledDate: scheduledDate,
      channelId: AppConstants.fertilizingChannelId,
      channelName: AppConstants.fertilizingChannelName,
      channelDescription: AppConstants.fertilizingChannelDescription,
      payload: 'fertilizing:$plantId',
    );
  }

  /// Cancels a specific scheduled reminder by [id].
  Future<void> cancelReminder(int id) async {
    _ensureInitialized();
    try {
      await _plugin.cancel(id);
    } catch (e) {
      throw NotificationException(
        message: 'Failed to cancel notification #$id.',
        details: e,
      );
    }
  }

  /// Cancels all scheduled and pending reminders.
  Future<void> cancelAllReminders() async {
    _ensureInitialized();
    try {
      await _plugin.cancelAll();
    } catch (e) {
      throw NotificationException(
        message: 'Failed to cancel all notifications.',
        details: e,
      );
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const NotificationException(
        message:
            'NotificationService has not been initialized. Call initialize() first.',
      );
    }
  }
}

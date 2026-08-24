import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class ReminderService {
  static final ReminderService _instance = ReminderService._();
  factory ReminderService() => _instance;
  ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _keyEnabled = 'reminder_enabled';
  static const _keyHour = 'reminder_hour';
  static const _keyMinute = 'reminder_minute';
  static const _channelId = 'study_reminders';
  static const _channelName = 'Study Reminders';
  static const _notificationId = 999;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Daily study reminders to keep you on track',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;

    // Re-schedule notification on every app launch (fixes app-killed scenario)
    final enabled = await isEnabled();
    if (enabled) {
      final hour = await getReminderHour();
      final minute = await getReminderMinute();
      await _scheduleDailyReminder(hour, minute);
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        // POST_NOTIFICATIONS permission (Android 13+)
        final granted = await android.requestNotificationsPermission();
        // SCHEDULE_EXACT_ALARM permission (Android 12+)
        await android.requestExactAlarmsPermission();
        return granted ?? false;
      }
    }
    return true;
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  Future<int> getReminderHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHour) ?? 20;
  }

  Future<int> getReminderMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMinute) ?? 0;
  }

  Future<void> setReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
    await prefs.setInt(_keyHour, hour);
    await prefs.setInt(_keyMinute, minute);

    if (enabled) {
      await _scheduleDailyReminder(hour, minute);
    } else {
      await _plugin.cancel(_notificationId);
    }
  }

  Future<void> _scheduleDailyReminder(int hour, int minute) async {
    // Cancel any existing scheduled notification first
    await _plugin.cancel(_notificationId);

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    // Use exactAllowWhileIdle for reliable delivery when app is killed
    await _plugin.zonedSchedule(
      _notificationId,
      'Time to Study!',
      _getRandomMessage(),
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Daily study reminders to keep you on track',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          enableLights: true,
          ongoing: false,
          autoCancel: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  String _getRandomMessage() {
    const messages = [
      'Your future self will thank you for studying today!',
      'Consistency is the key to success. Start your session!',
      'Every minute of study counts. Let\'s go!',
      'You\'re one step closer to your goal. Time to study!',
      'Knowledge is power. Power up your brain now!',
      'Don\'t break the chain! Study for a few minutes.',
      'Small daily improvements lead to stunning results.',
      'Your competitors are studying. Are you?',
      'Dream big, study hard. Start now!',
      'The best time to study was yesterday. The second best time is now!',
    ];
    final index = DateTime.now().millisecondsSinceEpoch % messages.length;
    return messages[index];
  }

  /// Debug method to test notification immediately
  Future<void> showTestNotification() async {
    await _plugin.show(
      _notificationId,
      'Test Notification',
      'If you see this, notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Test notification',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

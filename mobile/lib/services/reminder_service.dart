import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._();
  factory ReminderService() => _instance;
  ReminderService._();

  static const _keyEnabled = 'reminder_enabled';
  static const _keyHour = 'reminder_hour';
  static const _keyMinute = 'reminder_minute';
  static const _channelId = 'study_reminders';
  static const _notificationId = 999;

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: _channelId,
          channelName: 'Study Reminders',
          channelDescription: 'Daily study reminders to keep you on track',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF6C63FF),
          ledColor: const Color(0xFF6C63FF),
          enableVibration: true,
          enableLights: true,
          playSound: true,
        ),
      ],
    );

    // Listen for when app is opened via notification
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (details) async {},
      onNotificationCreatedMethod: (details) async {},
      onNotificationDisplayedMethod: (details) async {},
    );

    // Request permissions on init
    await requestPermissions();

    // Re-schedule on every app launch
    final enabled = await isEnabled();
    if (enabled) {
      final hour = await getReminderHour();
      final minute = await getReminderMinute();
      await _scheduleDaily(hour, minute);
    }
  }

  Future<bool> requestPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      final granted = await AwesomeNotifications().requestPermissionToSendNotifications();
      return granted;
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
      await requestPermissions();
      await _scheduleDaily(hour, minute);
    } else {
      await AwesomeNotifications().cancel(_notificationId);
    }
  }

  Future<void> _scheduleDaily(int hour, int minute) async {
    // Cancel existing
    await AwesomeNotifications().cancel(_notificationId);

    // Calculate next occurrence
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _notificationId,
        channelKey: _channelId,
        title: 'Time to Study!',
        body: _getRandomMessage(),
        notificationLayout: NotificationLayout.Default,
        autoDismissible: true,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        year: scheduled.year,
        month: scheduled.month,
        day: scheduled.day,
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
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

  Future<void> showTestNotification() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await requestPermissions();
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: _channelId,
        title: 'Test Notification',
        body: 'Notifications are working! You will get daily reminders.',
        notificationLayout: NotificationLayout.Default,
        autoDismissible: true,
        wakeUpScreen: true,
      ),
    );
  }

  /// Check if notification is scheduled for debugging
  Future<bool> isScheduled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }
}

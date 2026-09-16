import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:relax_mindfulness/main.dart' show localNotifications;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool _morningReminderEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);

  bool _eveningReminderEnabled = true;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 30);

  bool get morningReminderEnabled => _morningReminderEnabled;
  TimeOfDay get morningTime => _morningTime;
  bool get eveningReminderEnabled => _eveningReminderEnabled;
  TimeOfDay get eveningTime => _eveningTime;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }

    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _morningReminderEnabled = prefs.getBool('morning_reminder_enabled') ?? true;
    final morningHour = prefs.getInt('morning_reminder_hour') ?? 8;
    final morningMinute = prefs.getInt('morning_reminder_minute') ?? 0;
    _morningTime = TimeOfDay(hour: morningHour, minute: morningMinute);

    _eveningReminderEnabled = prefs.getBool('evening_reminder_enabled') ?? true;
    final eveningHour = prefs.getInt('evening_reminder_hour') ?? 21;
    final eveningMinute = prefs.getInt('evening_reminder_minute') ?? 30;
    _eveningTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);
  }

  Future<void> setMorningReminder(bool enabled, {TimeOfDay? time}) async {
    _morningReminderEnabled = enabled;
    if (time != null) _morningTime = time;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morning_reminder_enabled', _morningReminderEnabled);
    await prefs.setInt('morning_reminder_hour', _morningTime.hour);
    await prefs.setInt('morning_reminder_minute', _morningTime.minute);

    if (_morningReminderEnabled) {
      await scheduleMorningReminder();
    } else {
      await _notifications.cancel(101);
    }
  }

  Future<void> setEveningReminder(bool enabled, {TimeOfDay? time}) async {
    _eveningReminderEnabled = enabled;
    if (time != null) _eveningTime = time;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('evening_reminder_enabled', _eveningReminderEnabled);
    await prefs.setInt('evening_reminder_hour', _eveningTime.hour);
    await prefs.setInt('evening_reminder_minute', _eveningTime.minute);

    if (_eveningReminderEnabled) {
      await scheduleEveningReminder();
    } else {
      await _notifications.cancel(102);
    }
  }

  Future<void> scheduleMorningReminder() async {
    if (!_isInitialized) return;

    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, _morningTime.hour, _morningTime.minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await localNotifications.zonedSchedule(
        101,
        '🌸 Good Morning Sanctuary',
        'Take 5 minutes for gentle morning breath & clarity before starting your day. 🌿',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true)),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error showing morning notification: $e');
    }
  }

  Future<void> scheduleEveningReminder() async {
    if (!_isInitialized) return;

    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, _eveningTime.hour, _eveningTime.minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await localNotifications.zonedSchedule(
        102,
        '🌙 Time to Wind Down',
        'Your sleep story & ocean waves are ready. Drift off into deep rest. ✨',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true)),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error showing evening notification: $e');
    }
  }

  Future<void> sendInstantTestNotification() async {
    if (!_isInitialized) await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'sanctuary_test_channel',
        'Sanctuary Test Channel',
        channelDescription: 'Test notifications for Sanctuary app',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      999,
      '🪷 Sanctuary Notification Active',
      'Daily morning & bedtime reminders are scheduled. Peace is just a breath away!',
      details,
    );
  }
}

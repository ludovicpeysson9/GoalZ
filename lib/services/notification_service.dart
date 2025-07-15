import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:goalz/models/notification_settings.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzData.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleDaily(
    int hour,
    int minute,
    int id,
    String title,
    String body,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.local(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      ).add(const Duration(days: 1)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notif',
          'Daily Notifications',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMonthly(
    int day,
    int hour,
    int minute,
    int id,
    String title,
    String body,
  ) async {
    final now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, day, hour, minute);
    if (next.isBefore(now)) {
      next = DateTime(now.year, now.month + 1, day, hour, minute);
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(next, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monthly_notif',
          'Monthly Notifications',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> scheduleSpecificDate(
    int id,
    int year,
    int month,
    int day,
    int hour,
    int minute,
    String title,
    String body,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.local(year, month, day, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'specific_notif',
          'Specific Date Notifications',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> setupAllNotifications({
    required bool hasDailyGoals,
    required bool hasMonthlyGoals,
    required bool hasQuarterlyGoals,
    required bool hasAnnualGoals,
    required Map<String, NotificationSettings> config,
  }) async {
    if (hasDailyGoals) {
      if (config['dailyMorning']?.enabled ?? false) {
        await scheduleDaily(
          config['dailyMorning']!.hour,
          config['dailyMorning']!.minute,
          100,
          "Définissez vos objectifs aujourd'hui",
          "",
        );
      }
      if (config['dailyEvening']?.enabled ?? false) {
        await scheduleDaily(
          config['dailyEvening']!.hour,
          config['dailyEvening']!.minute,
          101,
          "Avez-vous rempli vos objectifs ?",
          "",
        );
      }
    }

    if (hasMonthlyGoals) {
      if (config['monthlyStart']?.enabled ?? false) {
        await scheduleMonthly(
          1,
          config['monthlyStart']!.hour,
          config['monthlyStart']!.minute,
          200,
          "Définissez vos objectifs du mois",
          "",
        );
      }
      if (config['monthlyMid']?.enabled ?? false) {
        await scheduleMonthly(
          14,
          config['monthlyMid']!.hour,
          config['monthlyMid']!.minute,
          201,
          "Avancez-vous sur vos objectifs ?",
          "",
        );
      }
      if (config['monthlyEnd']?.enabled ?? false) {
        await scheduleMonthly(
          28,
          config['monthlyEnd']!.hour,
          config['monthlyEnd']!.minute,
          202,
          "Avez-vous atteint vos objectifs ?",
          "",
        );
      }
    }

    if (hasQuarterlyGoals && (config['quarterly']?.enabled ?? false)) {
      for (int i = 1; i <= 12; i++) {
        await scheduleMonthly(
          1,
          config['quarterly']!.hour,
          config['quarterly']!.minute,
          300 + i,
          "Objectifs trimestriels : avancez-vous ?",
          "",
        );
      }
    }

    if (hasAnnualGoals && (config['yearly']?.enabled ?? false)) {
      final year = DateTime.now().year;
      await scheduleSpecificDate(
        400,
        year,
        3,
        1,
        config['yearly']!.hour,
        config['yearly']!.minute,
        "Objectifs annuels : point du 01/03",
        "",
      );
      await scheduleSpecificDate(
        401,
        year,
        6,
        1,
        config['yearly']!.hour,
        config['yearly']!.minute,
        "Objectifs annuels : point du 01/06",
        "",
      );
      await scheduleSpecificDate(
        402,
        year,
        9,
        1,
        config['yearly']!.hour,
        config['yearly']!.minute,
        "Objectifs annuels : point du 01/09",
        "",
      );
      await scheduleSpecificDate(
        403,
        year,
        12,
        31,
        config['yearly']!.hour,
        config['yearly']!.minute,
        "Bonne année ! Redéfinissez vos objectifs",
        "",
      );
    }
  }
}

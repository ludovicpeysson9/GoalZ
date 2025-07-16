// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tzData;
// import 'package:goalz/models/notification_settings.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     tzData.initializeTimeZones();

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const iosSettings = DarwinInitializationSettings();
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//     await flutterLocalNotificationsPlugin.initialize(initSettings);
//   }

//   Future<void> scheduleDaily(
//     int hour,
//     int minute,
//     int id,
//     String title,
//     String body,
//   ) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.local(
//         DateTime.now().year,
//         DateTime.now().month,
//         DateTime.now().day,
//         hour,
//         minute,
//       ).add(const Duration(days: 1)),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_notif',
//           'Daily Notifications',
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   Future<void> scheduleMonthly(
//     int day,
//     int hour,
//     int minute,
//     int id,
//     String title,
//     String body,
//   ) async {
//     final now = DateTime.now();
//     DateTime next = DateTime(now.year, now.month, day, hour, minute);
//     if (next.isBefore(now)) {
//       next = DateTime(now.year, now.month + 1, day, hour, minute);
//     }

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(next, tz.local),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'monthly_notif',
//           'Monthly Notifications',
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
//     );
//   }

//   Future<void> scheduleSpecificDate(
//     int id,
//     int year,
//     int month,
//     int day,
//     int hour,
//     int minute,
//     String title,
//     String body,
//   ) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.local(year, month, day, hour, minute),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'specific_notif',
//           'Specific Date Notifications',
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }

//   Future<void> setupAllNotifications({
//     required bool hasDailyGoals,
//     required bool hasMonthlyGoals,
//     required bool hasQuarterlyGoals,
//     required bool hasAnnualGoals,
//     required Map<String, NotificationSettings> config,
//   }) async {
//     if (hasDailyGoals) {
//       if (config['dailyMorning']?.enabled ?? false) {
//         await scheduleDaily(
//           config['dailyMorning']!.hour,
//           config['dailyMorning']!.minute,
//           100,
//           "Définissez vos objectifs aujourd'hui",
//           "",
//         );
//       }
//       if (config['dailyEvening']?.enabled ?? false) {
//         await scheduleDaily(
//           config['dailyEvening']!.hour,
//           config['dailyEvening']!.minute,
//           101,
//           "Avez-vous rempli vos objectifs ?",
//           "",
//         );
//       }
//     }

//     if (hasMonthlyGoals) {
//       if (config['monthlyStart']?.enabled ?? false) {
//         await scheduleMonthly(
//           1,
//           config['monthlyStart']!.hour,
//           config['monthlyStart']!.minute,
//           200,
//           "Définissez vos objectifs du mois",
//           "",
//         );
//       }
//       if (config['monthlyMid']?.enabled ?? false) {
//         await scheduleMonthly(
//           14,
//           config['monthlyMid']!.hour,
//           config['monthlyMid']!.minute,
//           201,
//           "Avancez-vous sur vos objectifs ?",
//           "",
//         );
//       }
//       if (config['monthlyEnd']?.enabled ?? false) {
//         await scheduleMonthly(
//           28,
//           config['monthlyEnd']!.hour,
//           config['monthlyEnd']!.minute,
//           202,
//           "Avez-vous atteint vos objectifs ?",
//           "",
//         );
//       }
//     }

//     if (hasQuarterlyGoals && (config['quarterly']?.enabled ?? false)) {
//       for (int i = 1; i <= 12; i++) {
//         await scheduleMonthly(
//           1,
//           config['quarterly']!.hour,
//           config['quarterly']!.minute,
//           300 + i,
//           "Objectifs trimestriels : avancez-vous ?",
//           "",
//         );
//       }
//     }

//     if (hasAnnualGoals && (config['yearly']?.enabled ?? false)) {
//       final year = DateTime.now().year;
//       await scheduleSpecificDate(
//         400,
//         year,
//         3,
//         1,
//         config['yearly']!.hour,
//         config['yearly']!.minute,
//         "Objectifs annuels : point du 01/03",
//         "",
//       );
//       await scheduleSpecificDate(
//         401,
//         year,
//         6,
//         1,
//         config['yearly']!.hour,
//         config['yearly']!.minute,
//         "Objectifs annuels : point du 01/06",
//         "",
//       );
//       await scheduleSpecificDate(
//         402,
//         year,
//         9,
//         1,
//         config['yearly']!.hour,
//         config['yearly']!.minute,
//         "Objectifs annuels : point du 01/09",
//         "",
//       );
//       await scheduleSpecificDate(
//         403,
//         year,
//         12,
//         31,
//         config['yearly']!.hour,
//         config['yearly']!.minute,
//         "Bonne année ! Redéfinissez vos objectifs",
//         "",
//       );
//     }
//   }
// }


import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:goalz/models/notification_settings.dart';
import 'package:goalz/services/settings_service.dart';
import 'package:goalz/services/goal_storage_service.dart';

class NotificationHelper {
  static Future<void> reconfigureNotifications() async {
    final notificationService = NotificationService();
    final settings = await SettingsService.loadSettings();
    final goalStorage = GoalStorageService();
    
    // Vérifier quels types d'objectifs existent
    final dailyGoals = await goalStorage.loadGoals('daily');
    final monthlyGoals = await goalStorage.loadGoals('monthly');
    final quarterlyGoals = await goalStorage.loadGoals('quarterly');
    final annualGoals = await goalStorage.loadGoals('annual');
    
    await notificationService.setupAllNotifications(
      hasDailyGoals: dailyGoals.isNotEmpty,
      hasMonthlyGoals: monthlyGoals.isNotEmpty,
      hasQuarterlyGoals: quarterlyGoals.isNotEmpty,
      hasAnnualGoals: annualGoals.isNotEmpty,
      config: settings,
    );
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzData.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<bool> requestPermissions() async {
    // Demander les permissions Android
    final androidPermission = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Demander les permissions iOS
    final iosPermission = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return androidPermission ?? iosPermission ?? false;
  }

  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    
    return true; // iOS ne permet pas de vérifier facilement
  }

  Future<void> scheduleDaily(
    int hour,
    int minute,
    int id,
    String title,
    String body,
  ) async {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // Si l'heure est déjà passée aujourd'hui, programmer pour demain
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notif',
          'Daily Notifications',
          importance: Importance.high,
          priority: Priority.high,
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
    
    // Si la date est déjà passée ce mois-ci, programmer pour le mois suivant
    if (next.isBefore(now)) {
      // Gérer le passage à l'année suivante
      if (now.month == 12) {
        next = DateTime(now.year + 1, 1, day, hour, minute);
      } else {
        next = DateTime(now.year, now.month + 1, day, hour, minute);
      }
    }

    // Gérer les mois avec moins de jours (ex: février avec 28 jours)
    if (day > 28) {
      final lastDayOfMonth = DateTime(next.year, next.month + 1, 0).day;
      if (day > lastDayOfMonth) {
        next = DateTime(next.year, next.month, lastDayOfMonth, hour, minute);
      }
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
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> scheduleQuarterly(
    int id,
    int hour,
    int minute,
    String title,
    String body,
  ) async {
    final now = DateTime.now();
    final currentYear = now.year;
    
    // Définir les dates trimestrielles : 1er janvier, 1er avril, 1er juillet, 1er octobre
    final quarterlyDates = [
      DateTime(currentYear, 1, 1, hour, minute),
      DateTime(currentYear, 4, 1, hour, minute),
      DateTime(currentYear, 7, 1, hour, minute),
      DateTime(currentYear, 10, 1, hour, minute),
    ];

    // Ajouter les dates de l'année suivante
    final nextYearDates = [
      DateTime(currentYear + 1, 1, 1, hour, minute),
      DateTime(currentYear + 1, 4, 1, hour, minute),
      DateTime(currentYear + 1, 7, 1, hour, minute),
      DateTime(currentYear + 1, 10, 1, hour, minute),
    ];

    quarterlyDates.addAll(nextYearDates);

    // Programmer les notifications pour les prochaines dates trimestrielles
    int notificationId = id;
    for (final date in quarterlyDates) {
      if (date.isAfter(now)) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          tz.TZDateTime.from(date, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'quarterly_notif',
              'Quarterly Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        notificationId++;
      }
    }
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
    final scheduledDate = DateTime(year, month, day, hour, minute);
    
    // Ne programmer que si la date est dans le futur
    if (scheduledDate.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'specific_notif',
            'Specific Date Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    await flutterLocalNotificationsPlugin.show(
      999,
      'Test Notification',
      'Si vous voyez ceci, les notifications fonctionnent !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleTestNotification() async {
    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(seconds: 5));
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      998,
      'Test Notification Programmée',
      'Notification programmée pour dans 5 secondes',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.high,
          priority: Priority.high,
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
    // Effacer toutes les notifications existantes
    await clearAllNotifications();

    // NOTIFICATIONS QUOTIDIENNES - Toujours actives selon les paramètres
    if (config['dailyMorning']?.enabled ?? false) {
      await scheduleDaily(
        config['dailyMorning']!.hour,
        config['dailyMorning']!.minute,
        100,
        "Définissez vos objectifs aujourd'hui",
        "Prenez quelques minutes pour planifier votre journée",
      );
    }
    if (config['dailyEvening']?.enabled ?? false) {
      await scheduleDaily(
        config['dailyEvening']!.hour,
        config['dailyEvening']!.minute,
        101,
        "Avez-vous rempli vos objectifs ?",
        "Faites le point sur votre journée",
      );
    }

    // NOTIFICATIONS MENSUELLES - Toujours actives selon les paramètres
    if (config['monthlyStart']?.enabled ?? false) {
      await scheduleMonthly(
        1,
        config['monthlyStart']!.hour,
        config['monthlyStart']!.minute,
        200,
        "Définissez vos objectifs du mois",
        "Que souhaitez-vous accomplir ce mois-ci ?",
      );
    }
    
    // Les notifications de suivi ne se programment que si il y a des objectifs mensuels
    if (hasMonthlyGoals) {
      if (config['monthlyMid']?.enabled ?? false) {
        await scheduleMonthly(
          14,
          config['monthlyMid']!.hour,
          config['monthlyMid']!.minute,
          201,
          "Avancez-vous sur vos objectifs ?",
          "Point à mi-parcours de vos objectifs mensuels",
        );
      }
      if (config['monthlyEnd']?.enabled ?? false) {
        await scheduleMonthly(
          28,
          config['monthlyEnd']!.hour,
          config['monthlyEnd']!.minute,
          202,
          "Avez-vous atteint vos objectifs ?",
          "Bilan de fin de mois",
        );
      }
    }

    // NOTIFICATIONS TRIMESTRIELLES - Seulement si l'utilisateur a des objectifs trimestriels
    if (hasQuarterlyGoals && (config['quarterly']?.enabled ?? false)) {
      await scheduleQuarterly(
        300,
        config['quarterly']!.hour,
        config['quarterly']!.minute,
        "Objectifs trimestriels : avancez-vous ?",
        "Point sur vos objectifs trimestriels",
      );
    }

    // NOTIFICATIONS ANNUELLES - Seulement si l'utilisateur a des objectifs annuels
    if (hasAnnualGoals && (config['yearly']?.enabled ?? false)) {
      final currentYear = DateTime.now().year;
      final nextYear = currentYear + 1;
      
      // Programmer pour l'année actuelle et suivante
      for (final year in [currentYear, nextYear]) {
        await scheduleSpecificDate(
          400 + (year - currentYear) * 10,
          year,
          3,
          1,
          config['yearly']!.hour,
          config['yearly']!.minute,
          "Objectifs annuels : point du 01/03",
          "Premier trimestre terminé, faites le point !",
        );
        await scheduleSpecificDate(
          401 + (year - currentYear) * 10,
          year,
          6,
          1,
          config['yearly']!.hour,
          config['yearly']!.minute,
          "Objectifs annuels : point du 01/06",
          "Mi-année, où en êtes-vous ?",
        );
        await scheduleSpecificDate(
          402 + (year - currentYear) * 10,
          year,
          9,
          1,
          config['yearly']!.hour,
          config['yearly']!.minute,
          "Objectifs annuels : point du 01/09",
          "Troisième trimestre, dernière ligne droite !",
        );
        await scheduleSpecificDate(
          403 + (year - currentYear) * 10,
          year,
          12,
          31,
          config['yearly']!.hour,
          config['yearly']!.minute,
          "Bonne année ! Redéfinissez vos objectifs",
          "Préparez vos objectifs pour la nouvelle année",
        );
      }
    }
  }
}
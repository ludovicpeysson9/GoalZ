import 'package:flutter/material.dart';
import 'screens/goalz_screen.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/goal_storage_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:goalz/services/goal_cron.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

Future<void> _setupNotifications() async {
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

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  // Initialiser les time zones
  tz.initializeTimeZones();
  
  // Initialiser AndroidAlarmManager
  await AndroidAlarmManager.initialize();
  
  // Initialiser le service de notifications
  final notificationService = NotificationService();
  await notificationService.init();
  
  // CRUCIAL : Demander les permissions de notifications
  await notificationService.requestPermissions();
  
  // Initialiser les paramètres par défaut
  await SettingsService.saveDefaultSettings(); 
  
  // Programmer les tâches cron
  await GoalCron.scheduleAll();
  await GoalCron.catchUpMissedRuns();
  
  // CRUCIAL : Configurer les notifications selon les paramètres
  await _setupNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoalZ',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [ Locale('fr'), Locale('en') ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const GoalZScreen(),
    );
  }
}
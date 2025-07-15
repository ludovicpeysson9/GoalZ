import 'package:flutter/material.dart';
import 'screens/goalz_screen.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:goalz/services/goal_cron.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  tz.initializeTimeZones();
  await NotificationService().init();
  await SettingsService.saveDefaultSettings(); 
  await GoalCron.scheduleAll();
  await GoalCron.catchUpMissedRuns();

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

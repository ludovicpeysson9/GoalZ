// lib/services/goal_cron.dart - Version corrigée
import 'dart:isolate';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'goal_storage_service.dart';

// IDs stables pour qu'on puisse cancel si besoin.
const _idDaily      = 101;
const _idMonthly    = 102;
const _idQuarterly  = 103;
const _idYearly     = 104;

abstract class GoalCron {

  /* ---------------- SCHEDULING ---------------- */

  static Future<void> scheduleAll() async {
    await _scheduleDaily();
    await _scheduleMonthly();
    await _scheduleQuarterly();
    await _scheduleYearly();
  }

  static Future<void> _scheduleDaily() async {
    final now = tz.TZDateTime.now(tz.local);
    // ✅ CORRECTION : Programmer pour minuit (0h00) au lieu de 23h59
    final next = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 0, 0);
    
    print('🕐 Scheduling daily worker for: $next');
    
    await AndroidAlarmManager.oneShotAt(next, _idDaily, _dailyWorker,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  static Future<void> _scheduleMonthly() async {
    final now = tz.TZDateTime.now(tz.local);
    // ✅ CORRECTION : Premier jour du mois suivant à minuit
    final next = tz.TZDateTime(tz.local, now.year, now.month + 1, 1, 0, 0);
    
    print('🗓️ Scheduling monthly worker for: $next');
    
    await AndroidAlarmManager.oneShotAt(next, _idMonthly, _monthlyWorker,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  static Future<void> _scheduleQuarterly() async {
    final now = tz.TZDateTime.now(tz.local);
    
    // Trouver le prochain premier jour de trimestre
    int nextQuarterMonth;
    if (now.month <= 3) {
      nextQuarterMonth = 4; // Avril
    } else if (now.month <= 6) {
      nextQuarterMonth = 7; // Juillet
    } else if (now.month <= 9) {
      nextQuarterMonth = 10; // Octobre
    } else {
      nextQuarterMonth = 1; // Janvier suivant
    }
    
    final nextYear = nextQuarterMonth == 1 ? now.year + 1 : now.year;
    final next = tz.TZDateTime(tz.local, nextYear, nextQuarterMonth, 1, 0, 0);
    
    print('📅 Scheduling quarterly worker for: $next');
    
    await AndroidAlarmManager.oneShotAt(next, _idQuarterly, _quarterlyWorker,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  static Future<void> _scheduleYearly() async {
    final now = tz.TZDateTime.now(tz.local);
    // ✅ CORRECTION : Premier janvier suivant à minuit
    final next = tz.TZDateTime(tz.local, now.year + 1, 1, 1, 0, 0);
    
    print('🎆 Scheduling yearly worker for: $next');
    
    await AndroidAlarmManager.oneShotAt(next, _idYearly, _yearlyWorker,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  /* --------- WORKERS (top-level = requis par AlarmManager) --------- */

  static Future<void> _dailyWorker() async {
    print('🔄 Daily worker executing at ${DateTime.now()}');
    
    final s = GoalStorageService();
    final goals = await s.loadGoals('daily');

    print('🤖 Found ${goals.length} daily goals to process');
    if (goals.isNotEmpty) {
      final allDone = goals.every((g) => (g['checks'] as List).every((c) => c == true));
      print('🤖 All goals accomplished: $allDone');
      print('🤖 About to increment stat: daily -> ${allDone ? 'accomplished' : 'ignored'}');
      await s.incrementStat('daily', allDone ? 'accomplished' : 'ignored');
      
      print('Daily goals accomplished: $allDone');
      print('Processing ${goals.length} daily goals');
    }
    
    // ✅ NOUVELLE LOGIQUE : Garder seulement les objectifs avec autoRepeat
    final goalsToKeep = <Map<String, dynamic>>[];
    
    for (final goal in goals) {
      final autoRepeat = goal['autoRepeat'] as bool? ?? false;
      if (autoRepeat) {
        // Créer une copie de l'objectif avec checks réinitialisés
        final timesPerDay = goal['timesPerDay'] as int? ?? 1;
        final renewedGoal = Map<String, dynamic>.from(goal);
        renewedGoal['checks'] = List.filled(timesPerDay, false);
        goalsToKeep.add(renewedGoal);
        print('✅ Renewed daily goal: ${goal['title']}');
      } else {
        print('🗑️ Removed daily goal: ${goal['title']}');
      }
    }
    
    await s.saveGoals('daily', goalsToKeep);
    print('Daily processing complete. Kept ${goalsToKeep.length} recurring goals');
    
    await _scheduleDaily(); // Planifier le suivant
  }

  static Future<void> _monthlyWorker() async {
    print('🔄 Monthly worker executing at ${DateTime.now()}');
    
    final s = GoalStorageService();
    final goals = await s.loadGoals('monthly');
    
    if (goals.isNotEmpty) {
      final done = goals.every((m) => (m['checks'] as List).every((c) => c == true));
      await s.incrementStat('monthly', done ? 'accomplished' : 'ignored');
      
      print('Monthly goals accomplished: $done');
      print('Processing ${goals.length} monthly goals');
    }
    
    // ✅ GARDER les objectifs avec autoRepeat
    final goalsToKeep = <Map<String, dynamic>>[];
    
    for (final goal in goals) {
      final autoRepeat = goal['autoRepeat'] as bool? ?? false;
      if (autoRepeat) {
        final timesPerDay = goal['timesPerDay'] as int? ?? 1;
        final renewedGoal = Map<String, dynamic>.from(goal);
        renewedGoal['checks'] = List.filled(timesPerDay, false);
        goalsToKeep.add(renewedGoal);
        print('✅ Renewed monthly goal: ${goal['title']}');
      } else {
        print('🗑️ Removed monthly goal: ${goal['title']}');
      }
    }
    
    await s.saveGoals('monthly', goalsToKeep);
    print('Monthly processing complete. Kept ${goalsToKeep.length} recurring goals');
    
    await _scheduleMonthly();
  }

  static Future<void> _quarterlyWorker() async {
    print('🔄 Quarterly worker executing at ${DateTime.now()}');
    
    final s = GoalStorageService();
    final goals = await s.loadGoals('quarterly');
    
    if (goals.isNotEmpty) {
      final done = goals.every((q) => (q['checks'] as List).every((c) => c == true));
      await s.incrementStat('quarterly', done ? 'accomplished' : 'ignored');
      
      print('Quarterly goals accomplished: $done');
      print('Processing ${goals.length} quarterly goals');
    }
    
    // ✅ GARDER les objectifs avec autoRepeat
    final goalsToKeep = <Map<String, dynamic>>[];
    
    for (final goal in goals) {
      final autoRepeat = goal['autoRepeat'] as bool? ?? false;
      if (autoRepeat) {
        final timesPerDay = goal['timesPerDay'] as int? ?? 1;
        final renewedGoal = Map<String, dynamic>.from(goal);
        renewedGoal['checks'] = List.filled(timesPerDay, false);
        goalsToKeep.add(renewedGoal);
        print('✅ Renewed quarterly goal: ${goal['title']}');
      } else {
        print('🗑️ Removed quarterly goal: ${goal['title']}');
      }
    }
    
    await s.saveGoals('quarterly', goalsToKeep);
    print('Quarterly processing complete. Kept ${goalsToKeep.length} recurring goals');
    
    await _scheduleQuarterly();
  }

  static Future<void> _yearlyWorker() async {
    print('🔄 Yearly worker executing at ${DateTime.now()}');
    
    final s = GoalStorageService();
    final goals = await s.loadGoals('annual');
    
    if (goals.isNotEmpty) {
      final done = goals.every((y) => (y['checks'] as List).every((c) => c == true));
      await s.incrementStat('annual', done ? 'accomplished' : 'ignored');
      
      print('Annual goals accomplished: $done');
      print('Processing ${goals.length} annual goals');
    }
    
    // ✅ GARDER les objectifs avec autoRepeat
    final goalsToKeep = <Map<String, dynamic>>[];
    
    for (final goal in goals) {
      final autoRepeat = goal['autoRepeat'] as bool? ?? false;
      if (autoRepeat) {
        final timesPerDay = goal['timesPerDay'] as int? ?? 1;
        final renewedGoal = Map<String, dynamic>.from(goal);
        renewedGoal['checks'] = List.filled(timesPerDay, false);
        goalsToKeep.add(renewedGoal);
        print('✅ Renewed annual goal: ${goal['title']}');
      } else {
        print('🗑️ Removed annual goal: ${goal['title']}');
      }
    }
    
    await s.saveGoals('annual', goalsToKeep);
    print('Annual processing complete. Kept ${goalsToKeep.length} recurring goals');
    
    await _scheduleYearly();
  }

  static Future<void> catchUpMissedRuns() async {
    print('🔍 Checking for missed runs...');
    // TODO: Implémenter la logique de rattrapage si nécessaire
  }
}
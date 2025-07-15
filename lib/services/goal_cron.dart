// lib/services/goal_cron.dart
import 'dart:isolate';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'goal_storage_service.dart';

// IDs stables pour qu’on puisse cancel si besoin.
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
    final now   = tz.TZDateTime.now(tz.local);
    final next  = tz.TZDateTime(tz.local, now.year, now.month, now.day, 23, 59)
                  .add(const Duration(days: 1));
    await AndroidAlarmManager.oneShotAt(next, _idDaily, _dailyWorker,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  static Future<void> _scheduleMonthly() async {
    final now = tz.TZDateTime.now(tz.local);
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final next = tz.TZDateTime(
        tz.local, now.year, now.month, lastDay, 23, 59).add(const Duration(days: 1));
    await AndroidAlarmManager.oneShotAt(next, _idMonthly, _monthlyWorker,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  static Future<void> _scheduleQuarterly() async {
    final now = tz.TZDateTime.now(tz.local);
    int nextMonth = (now.month <= 3)
        ? 3
        : (now.month <= 6)
            ? 6
            : (now.month <= 9)
                ? 9
                : 12;
    if (now.month == nextMonth && now.day == 31) nextMonth += 3; // évite today
    final lastDay = DateTime(now.year, nextMonth + 1, 0).day;
    final next = tz.TZDateTime(
            tz.local, now.year, nextMonth, lastDay, 23, 59)
        .add(const Duration(days: 1));
    await AndroidAlarmManager.oneShotAt(next, _idQuarterly, _quarterlyWorker,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  static Future<void> _scheduleYearly() async {
    final now  = tz.TZDateTime.now(tz.local);
    final next = tz.TZDateTime(tz.local, now.year, 12, 31, 23, 59)
                 .add(const Duration(days: 1));
    await AndroidAlarmManager.oneShotAt(next, _idYearly, _yearlyWorker,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  /* --------- WORKERS (top-level = requis par AlarmManager) --------- */

  static Future<void> _dailyWorker() async {
    final s = GoalStorageService();
    final goals = await s.loadGoals('daily');
    if (goals.isNotEmpty) {
      final allDone =
          goals.every((g) => (g['checks'] as List).every((c) => c == true));
      await s.incrementStat('daily', allDone ? 'accomplished' : 'ignored');
    }
    await s.saveGoals('daily', []);               // purge
    await _scheduleDaily();                       // planifie le suivant
  }

  static Future<void> _monthlyWorker() async {
    final s = GoalStorageService();
    final g = await s.loadGoals('monthly');
    if (g.isNotEmpty) {
      final done =
          g.every((m) => (m['checks'] as List).every((c) => c == true));
      await s.incrementStat('monthly', done ? 'accomplished' : 'ignored');
    }
    await s.saveGoals('monthly', []);
    await _scheduleMonthly();
  }

  static Future<void> _quarterlyWorker() async {
    final s = GoalStorageService();
    final g = await s.loadGoals('quarterly');
    if (g.isNotEmpty) {
      final done =
          g.every((q) => (q['checks'] as List).every((c) => c == true));
      await s.incrementStat('quarterly', done ? 'accomplished' : 'ignored');
    }
    await s.saveGoals('quarterly', []);
    await _scheduleQuarterly();
  }

  static Future<void> _yearlyWorker() async {
    final s = GoalStorageService();
    final g = await s.loadGoals('annual');
    if (g.isNotEmpty) {
      final done =
          g.every((y) => (y['checks'] as List).every((c) => c == true));
      await s.incrementStat('annual', done ? 'accomplished' : 'ignored');
    }
    await s.saveGoals('annual', []);
    await _scheduleYearly();
  }


  static Future<void> catchUpMissedRuns() async {
    final storage = GoalStorageService();
    final now     = DateTime.now();
  }
}

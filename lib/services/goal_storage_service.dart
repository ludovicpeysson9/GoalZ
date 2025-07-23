import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GoalStorageService {
  static const String _fileName = 'goals.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, dynamic>> _readData() async {
    final file = await _getFile();
    if (!await file.exists()) {
      await _initFile();
    }
    final content = await file.readAsString();
    return jsonDecode(content);
  }

  Future<void> _initFile() async {
    print('🔧 INITIALIZING NEW FILE');
    print('🔧 Stack trace:');
    print(StackTrace.current);
    print('🔧 =====================================');
    final file = await _getFile();
    final now = DateTime.now().toIso8601String().split('T').first;
    final initialData = {
      "startDate": now,
      "dailyGoals": [],
      "monthlyGoals": [],
      "quarterlyGoals": [],
      "annualGoals": [],
      "accomplishmentStats": {
        "daily": {"accomplished": 0, "ignored": 0},
        "monthly": {"accomplished": 0, "ignored": 0},
        "quarterly": {"accomplished": 0, "ignored": 0},
        "annual": {"accomplished": 0, "ignored": 0},
      },
      "lastDailyProcessedDate": "",
      "lastMonthlyProcessedDate": "",
      "lastQuarterlyProcessedDate": "",
      "lastAnnualProcessedDate": "",
      "appInstallDate": now,
    };
    await file.writeAsString(jsonEncode(initialData));
    print('🔧 File initialized with clean stats');
  }

  Future<void> saveGoals(String type, List<Map<String, dynamic>> goals) async {
    final data = await _readData();
    data['${type}Goals'] = goals;
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> loadGoals(String type) async {
    final data = await _readData();
    final raw = data['${type}Goals'];
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  Future<void> incrementStat(String type, String key) async {
    // ✅ LOG DÉTAILLÉ avec stack trace
    print('🚨 INCREMENTING STAT: $type -> $key');
    print('🚨 Stack trace:');
    print(StackTrace.current);
    print('🚨 =====================================');

    final data = await _readData();
    final stats = data['accomplishmentStats'];

    if (stats[type] != null && stats[type][key] != null) {
      stats[type][key]++;
    } else {
      stats[type] = stats[type] ?? {};
      stats[type][key] = 1;
    }

    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
    print('📊 New stats for $type: ${stats[type]}');
  }

  Future<Map<String, dynamic>> loadStats() async {
    final data = await _readData();
    return Map<String, dynamic>.from(data['accomplishmentStats']);
  }

  Future<bool> isFreshInstall() async {
    final file = await _getFile();
    final exists = await file.exists();
    print('📁 File exists: $exists');

    if (!exists) {
      print('📁 This is a fresh install - no data file exists');
      return true;
    }

    final data = await _readData();
    final installDate = data['appInstallDate'] as String?;
    final today = DateTime.now().toIso8601String().split('T').first;

    print('📁 Install date from file: $installDate');
    print('📁 Today: $today');
    if (installDate == null) {
      print('📁 Old file detected (no install date) - treating as fresh');
      return true;
    }
    return installDate == today;
  }

  Future<void> forceCleanReset() async {
    print('🧹 FORCING COMPLETE CLEAN RESET');
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
      print('🧹 Deleted existing data file');
    }
    await _initFile();
    print('🧹 Created fresh data file');
  }

  Future<void> resetAll() async => _initFile();
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/notification_settings.dart';


class SettingsNotifier {
  static final ValueNotifier<bool> showStatsNotifier = ValueNotifier(true);
}


class SettingsService {
  static Future<File> _getSettingsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/settings.json');
  }

  static Future<Map<String, NotificationSettings>> loadSettings() async {
    final file = await _getSettingsFile();

    if (!await file.exists()) {
      await saveDefaultSettings();
    }

    final content = await file.readAsString();
    final data = json.decode(content) as Map<String, dynamic>;

    final notifEntries = data.entries
        .where((e) => e.value is Map<String, dynamic>)
        .map((e) => MapEntry(e.key, NotificationSettings.fromJson(e.value)));

    return Map<String, NotificationSettings>.fromEntries(notifEntries);
  }

  static Future<void> saveSettings(
    Map<String, NotificationSettings> settings,
  ) async {
    final file = await _getSettingsFile();
    final data = settings.map((key, value) => MapEntry(key, value.toJson()));
    await file.writeAsString(json.encode(data));
  }

  static Future<void> saveDefaultSettings() async {
    final defaultSettings = {
      "dailyMorning": NotificationSettings(enabled: true, hour: 8, minute: 0),
      "dailyEvening": NotificationSettings(enabled: true, hour: 21, minute: 0),
      "monthlyStart": NotificationSettings(enabled: true, hour: 8, minute: 0),
      "monthlyMid": NotificationSettings(enabled: true, hour: 12, minute: 0),
      "monthlyEnd": NotificationSettings(enabled: true, hour: 20, minute: 0),
      "quarterly": NotificationSettings(enabled: true, hour: 12, minute: 0),
      "yearly": NotificationSettings(enabled: true, hour: 12, minute: 0),
    };
    await saveSettings(defaultSettings);
  }

  static Future<bool> getShowStats() async {
    final file = await _getSettingsFile();
    if (!await file.exists()) return true; 
    final content = await file.readAsString();
    final data = json.decode(content) as Map<String, dynamic>;
    return data['showStats'] ?? true;
  }

  static Future<void> setShowStats(bool value) async {
    final file = await _getSettingsFile();
    Map<String, dynamic> data = {};
    if (await file.exists()) {
      data = json.decode(await file.readAsString()) as Map<String, dynamic>;
    }

    data['showStats'] = value;

    final notificationSettings = Map<String, NotificationSettings>.fromEntries(
      data.entries
          .where((e) => e.value is Map<String, dynamic>)
          .map((e) => MapEntry(e.key, NotificationSettings.fromJson(e.value))),
    );
    await saveSettings(notificationSettings);
    final updatedFile = await _getSettingsFile();
    final updated = {
      ...notificationSettings.map((k, v) => MapEntry(k, v.toJson())),
      'showStats': value,
    };
    await updatedFile.writeAsString(json.encode(updated));
    SettingsNotifier.showStatsNotifier.value = value;

  }
}

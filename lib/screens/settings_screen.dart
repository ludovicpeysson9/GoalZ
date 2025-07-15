import 'package:flutter/material.dart';
import 'package:goalz/l10n/app_localizations.dart';
import '../services/settings_service.dart';
import '../models/notification_settings.dart';
import '../utils/context_extension.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Map<String, NotificationSettings> _settings;
  bool _loading = true;

  bool _showStats = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _toggleShowStats(bool value) async {
    setState(() => _showStats = value);
    await SettingsService.setShowStats(value);
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.loadSettings();
    final showStats = await SettingsService.getShowStats();
    SettingsNotifier.showStatsNotifier.value = showStats;
    setState(() {
      _settings = settings;
      _showStats = showStats;
      _loading = false;
    });
  }

  Future<void> _updateSetting(String key, NotificationSettings newValue) async {
    setState(() => _settings[key] = newValue);
    await SettingsService.saveSettings(_settings);
  }

  Widget _buildTimeSelector(String label, String key, bool enabled) {
    final setting = _settings[key]!;
    final time = TimeOfDay(hour: setting.hour, minute: setting.minute);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Switch(
              value: setting.enabled,
              onChanged: enabled
                  ? (val) => _updateSetting(key, setting.copyWith(enabled: val))
                  : null,
            ),
            TextButton(
              onPressed: enabled
                  ? () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: time,
                      );
                      if (picked != null) {
                        _updateSetting(
                          key,
                          setting.copyWith(
                            hour: picked.hour,
                            minute: picked.minute,
                          ),
                        );
                      }
                    }
                  : null,
              child: Text(
                '${setting.hour.toString().padLeft(2, '0')}:${setting.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.t(L10nKey.settingsTitle)),
        backgroundColor: Colors.deepOrange,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    context.loc.t(L10nKey.dailyNotifications),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildTimeSelector(context.loc.t(L10nKey.morning), 'dailyMorning', true),
                  _buildTimeSelector(context.loc.t(L10nKey.evening), 'dailyEvening', true),

                  const SizedBox(height: 20),
                  Text(
                    context.loc.t(L10nKey.monthlyNotifications),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildTimeSelector(
                    context.loc.t(L10nKey.startMonth),
                    'monthlyStart',
                    _settings['monthlyStart']!.enabled,
                  ),
                  _buildTimeSelector(
                    context.loc.t(L10nKey.halfMonth),
                    'monthlyMid',
                    _settings['monthlyMid']!.enabled,
                  ),
                  _buildTimeSelector(
                    context.loc.t(L10nKey.endMonth),
                    'monthlyEnd',
                    _settings['monthlyEnd']!.enabled,
                  ),

                  const SizedBox(height: 20),
                  Text(
                    context.loc.t(L10nKey.quarterlyNotifications),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildTimeSelector(
                    context.loc.t(L10nKey.firstDayOfMonth),
                    'quarterly',
                    _settings['quarterly']!.enabled,
                  ),

                  const SizedBox(height: 20),
                  Text(
                    context.loc.t(L10nKey.annualyNotifications),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildTimeSelector(
                    '01/03, 01/06, 01/09',
                    'yearly',
                    _settings['yearly']!.enabled,
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/stats.png',
                            height: 24,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 10),
                          Text(context.loc.t(L10nKey.displayStats)),
                        ],
                      ),
                      Switch(
                        value: _showStats,
                        onChanged: (value) => _toggleShowStats(value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:goalz/l10n/app_localizations.dart';
import '../services/goal_storage_service.dart';
import '../widgets/donut_stat.dart';
import '../utils/context_extension.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await GoalStorageService().loadStats();
    setState(() {
      _stats = loaded;
      _loading = false;
    });
  }

  Widget _buildLine(String type, String label) {
    final data = _stats[type] ?? {};
    final done = (data['accomplished'] ?? 0) as int;
    final ignored = (data['ignored'] ?? 0) as int;
    final total = done + ignored;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,   
      children: [
        DonutStat(accomplished: done, ignored: ignored),
        const SizedBox(width: 80),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'ArchiveBlack',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(context.loc.t(L10nKey.accomplished) + '$done'),
            Text(context.loc.t(L10nKey.ignored) + '$ignored'),
            Text('Total     : $total'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const mapping = {
      'daily':     'Daily',
      'monthly':   'Monthly',
      'quarterly': 'Quarterly',
      'annual':    'Annually',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.t(L10nKey.statsTitle)),
        backgroundColor :Color.fromRGBO(255, 99, 51, 1), 
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                    children: mapping.entries
                        .map((e) => _buildLine(e.key, e.value))
                        .toList(),
                  ),
                );
              },
            ),
    );
  }
}

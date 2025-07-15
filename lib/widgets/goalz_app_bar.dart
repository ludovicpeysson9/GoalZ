import 'package:flutter/material.dart';
import 'package:goalz/screens/settings_screen.dart';
import 'package:goalz/screens/stats_screen.dart';
import '../services/settings_service.dart';

class GoalZAppBar extends StatefulWidget implements PreferredSizeWidget {
  final BuildContext context;
  const GoalZAppBar({super.key, required this.context});

  @override
  State<GoalZAppBar> createState() => _GoalZAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}

class _GoalZAppBarState extends State<GoalZAppBar> {

  @override
  void initState() {
    super.initState();
    SettingsNotifier.showStatsNotifier.addListener(_onShowStatsChanged);
  }

  @override
  void dispose() {
    SettingsNotifier.showStatsNotifier.removeListener(_onShowStatsChanged);
    super.dispose();
  }

  void _onShowStatsChanged() {
    if (!mounted) return; 
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsNotifier.showStatsNotifier,
      builder: (_, showStats, __) {
        return AppBar(
          backgroundColor: Colors.orange,
          toolbarHeight: kToolbarHeight + 12,
          centerTitle: true,

          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 6.0),
            child: GestureDetector(
              onTap: showStats
                  ? () {
                      Navigator.push(
                        widget.context,
                        MaterialPageRoute(builder: (_) => const StatsScreen()),
                      );
                    }
                  : null,
              child: Opacity(
                opacity: showStats ? 1.0 : 0.3,
                child: Image.asset(
                  'assets/icons/stats.png',
                  height: 28,
                  width: 28,
                ),
              ),
            ),
          ),

          title: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: const Text(
              'GoalZ 🎯',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 6.0),
              child: IconButton(
                icon: const Icon(Icons.settings, size: 30, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    widget.context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

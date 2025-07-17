import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goalz/l10n/app_localizations.dart';
import '../services/goal_storage_service.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_form.dart';
import 'edit_goal_screen.dart';
import '../models/goal.dart';
import '../widgets/goalz_app_bar.dart';
import '../widgets/custom_calendar_stamp.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../utils/context_extension.dart';

class GoalZScreen extends StatefulWidget {
  const GoalZScreen({super.key});

  @override
  State<GoalZScreen> createState() => _GoalZScreenState();
}

class _GoalZScreenState extends State<GoalZScreen> {
  final PageController _controller = PageController();
  final List<String> _labels = ['Daily', 'Monthly', 'Quarterly', 'Annually'];
  final GoalStorageService storageService = GoalStorageService();

  Map<int, List<Goal>> goalsByType = {0: [], 1: [], 2: [], 3: []};
  Map<int, bool> dayAccomplished = {0: false, 1: false, 2: false, 3: false};
  bool isFormOpen = false;

  @override
  void initState() {
    super.initState();
    _loadAllGoals();
    _setupDailyTimer();
  }

  Future<void> _loadAllGoals() async {
    for (int i = 0; i < 4; i++) {
      String type = _labels[i].toLowerCase();
      final goalMaps = await storageService.loadGoals(type);
      setState(() {
        goalsByType[i] = goalMaps.map((e) => Goal.fromJson(e)).toList();
        _updateDayAccomplished(i);
      });
    }
  }

  void _setupDailyTimer() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 23, 59);
    final duration = target.difference(now);
    Timer(duration, _checkDailyAccomplished);
  }

  void _checkDailyAccomplished() async {
    final dailyGoals = goalsByType[0];
    if (dailyGoals == null || dailyGoals.isEmpty) return;

    final allDone = dailyGoals.every((g) => g.checks.every((c) => c));

    await storageService.incrementStat(
      "daily",
      allDone ? "accomplished" : "ignored",
    );
  }

  void _addGoal(int type, String title, String? info, int timesPerDay, bool autoRepeat) async {
    final goal = Goal(
      title: title,
      info: info,
      timesPerDay: timesPerDay,
      checks: List.filled(timesPerDay, false),
      autoRepeat: autoRepeat
    );
    setState(() {
      goalsByType[type]!.add(goal);
      isFormOpen = false;
    });
    await _saveGoals(type);
    _updateDayAccomplished(type);
  }

  Future<void> _saveGoals(int type) async {
    final typeKey = _labels[type].toLowerCase();
    final goalList = goalsByType[type]!;
    await storageService.saveGoals(
      typeKey,
      goalList.map((g) => g.toJson()).toList(),
    );
  }

  void _toggleCheck(int type, int goalIndex, int checkIndex, bool value) async {
    setState(() {
      goalsByType[type]![goalIndex].checks[checkIndex] = value;
    });
    await _saveGoals(type);
    _updateDayAccomplished(type);
  }

  void _updateDayAccomplished(int type) {
    final goals = goalsByType[type]!;
    final accomplished =
        goals.isNotEmpty && goals.every((g) => g.checks.every((c) => c));
    setState(() {
      dayAccomplished[type] = accomplished;
    });
  }

  void _editGoal(int type, int index) async {
    final goal = goalsByType[type]![index];
    final updatedMap = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditGoalScreen(
          goal: goal.toJson(),
          onSave: (updatedJson) {
            final updatedGoal = Goal.fromJson(updatedJson);
            setState(() {
              goalsByType[type]![index] = updatedGoal;
            });
            _saveGoals(type);
            _updateDayAccomplished(type);
          },
          onDelete: () {
            setState(() {
              goalsByType[type]!.removeAt(index);
            });
            _saveGoals(type);
            _updateDayAccomplished(type);
          },
        ),
      ),
    );

    if (updatedMap != null) {
      final updatedGoal = Goal.fromJson(updatedMap);
      setState(() {
        goalsByType[type]![index] = updatedGoal;
      });
      await _saveGoals(type);
      _updateDayAccomplished(type);
    }
  }

  void _toggleAllChecks(int type, bool checked) async {
    final list = goalsByType[type];
    if (list != null) {
      for (var goal in list) {
        goal.checks = List.filled(goal.checks.length, checked);
      }
    }
    await _saveGoals(type);
    _updateDayAccomplished(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GoalZAppBar(context: context),
      body: PageView.builder(
        controller: _controller,
        itemCount: 4,
        itemBuilder: (context, index) {
          final goals = goalsByType[index] ?? [];
          final label = _labels[index];
          final accomplished = dayAccomplished[index] == true;

          return Container(
            color: accomplished ? const Color(0xFFFFF8E1) : Colors.white,
            child: Stack(
              children: [
                Stack(
                  children: [
                    if (isFormOpen)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ),

                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/target.png',
                              height: 150,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'ArchiveBlack',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        const SizedBox(height: 80), 
                        Center(
                          child: CustomCalendarStamp(
                            type: (index == 0 || index == 1)
                                ? CalendarStampType.day
                                : CalendarStampType.yearMonth,
                          ),
                        ),

                        Expanded(
                          child: Stack(
                            children: [
                              ListView.builder(
                                itemCount: goals.length,
                                padding: const EdgeInsets.only(top: 40),
                                itemBuilder: (context, goalIndex) {
                                  final goal = goals[goalIndex];
                                  return GoalCard(
                                    title: goal.title,
                                    info: goal.info,
                                    timesPerDay: goal.timesPerDay,
                                    checks: goal.checks,
                                    onCheckChanged: (i, val) =>
                                        _toggleCheck(index, goalIndex, i, val),
                                    onEdit: () => _editGoal(index, goalIndex),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        if (!isFormOpen)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() => isFormOpen = true);
                              },
                              icon: const Icon(Icons.add),
                              label: Text(context.loc.t(L10nKey.addAGoal)),
                            ),
                          ),
                      ],
                    ),

                    // ✅ CORRECTION : Formulaire maintenant dans Stack principal (pas dans Column)
                    if (isFormOpen)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 300,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Stack(
                            children: [
                              GoalForm(
                                onSubmit: (title, info, times, repeat) =>
                                    _addGoal(index, title, info, times, repeat),
                                onFocusChange: (open) =>
                                    setState(() => isFormOpen = open),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      setState(() => isFormOpen = false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (accomplished)
                      Positioned(
                        top: 95,
                        left: 190,
                        right: 0,
                        child: AnimatedOpacity(
                          opacity: 0.8,
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeInOut,
                          child: Center(
                            child: Transform.rotate(
                              angle: -0.3,
                              child: Image.asset(
                                'assets/images/done.png',
                                width: 140,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ✅ CORRECTION : Masquer quand formulaire ouvert
                    if (!isFormOpen)
                      Positioned(
                        top: 15,
                        left: 15,
                        child: GestureDetector(
                          onTap: () async {
                            const url = 'https://buymeacoffee.com/ludovicpeysson';
                            final launched = await launchUrlString(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.loc.t(L10nKey.impossibleToOpenCoffeeLink)),
                                ),
                              );
                            }
                          },
                          child: Text(
                            context.loc.t(L10nKey.offerCoffee),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      ),

                    // ✅ CORRECTION : Masquer quand formulaire ouvert
                    if (goals.isNotEmpty && !isFormOpen)
                      Positioned(
                        top: 10,
                        right: 8,
                        child: IconButton(
                          icon: Icon(
                            accomplished ? Icons.clear : Icons.check,
                            color: accomplished ? Colors.red : Colors.green,
                            size: 30,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                  accomplished
                                      ? context.loc.t(L10nKey.reconsiderTheDay)
                                      : context.loc.t(L10nKey.isDayValidated),
                                ),
                                content: Text(
                                  accomplished
                                      ? context.loc.t(L10nKey.reconsiderTheDayText)
                                      : context.loc.t(L10nKey.isDayValidatedText),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(context.loc.t(L10nKey.no)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(context.loc.t(L10nKey.yes)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final newState = !accomplished;
                              _toggleAllChecks(index, newState);
                            }
                          },
                        ),
                      ),

                    if (!isFormOpen) ...[
                      Positioned(
                        left: -12,
                        top:
                            MediaQuery.of(context).size.height / 2 -
                            kToolbarHeight / 2 -
                            100,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            final prev = (_controller.page ?? 0).floor() - 1;
                            if (prev >= 0) {
                              _controller.animateToPage(
                                prev,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.1416),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Image.asset(
                                'assets/icons/chevron-droit.png',
                                height: 64,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -12,
                        top:
                            MediaQuery.of(context).size.height / 2 -
                            kToolbarHeight / 2 -
                            100,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            final next = (_controller.page ?? 0).floor() + 1;
                            if (next < 4) {
                              _controller.animateToPage(
                                next,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 0),
                            child: Image.asset(
                              'assets/icons/chevron-droit.png',
                              height: 64,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
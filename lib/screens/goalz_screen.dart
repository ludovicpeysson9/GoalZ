import 'package:flutter/material.dart';
import '../widgets/goalz_app_bar.dart';

class GoalZScreen extends StatelessWidget {
  const GoalZScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GoalZAppBar(context: context),
      body: const Center(
        child: Text(
          'Bienvenue sur GoalZ 🎯',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

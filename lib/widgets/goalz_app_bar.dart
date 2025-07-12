import 'package:flutter/material.dart';
import 'package:goalz/screens/goalz_screen.dart';
import 'package:goalz/screens/settings_screen.dart';

class GoalZAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext context;
  const GoalZAppBar({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      color: Colors.orange, // Couleur personnalisée
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48), // Placeholder

              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GoalZScreen(), // à créer
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'GoalZ 🎯',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.settings, size: 30, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}

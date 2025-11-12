import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ThemeToggle({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                "Light mode",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: themeMode == ThemeMode.dark,
                onChanged: (v) {
                  onThemeChanged(v ? ThemeMode.dark : ThemeMode.light);
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Dark mode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:food_budget_app/app.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = FoodBudgetApp.of(context);
    final isDark = appState.themeMode == ThemeMode.dark;
    final isHu = appState.locale == 'hu';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isHu ? 'Beállítások' : 'Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Theme toggle
          ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            title: Text(isHu ? 'Téma' : 'Theme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode, size: 18),
                  label: Text(isHu ? 'Világos' : 'Light',
                      style: const TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode, size: 18),
                  label: Text(isHu ? 'Sötét' : 'Dark',
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
              selected: {appState.themeMode},
              onSelectionChanged: (set) {
                appState.setThemeMode(set.first);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 8),

          // Language toggle
          ListTile(
            leading: Icon(
              Icons.language,
              color: theme.colorScheme.primary,
            ),
            title: Text(isHu ? 'Nyelv' : 'Language'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'hu',
                  label: Text('Magyar', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text('English', style: TextStyle(fontSize: 12)),
                ),
              ],
              selected: {appState.locale},
              onSelectionChanged: (set) {
                appState.setLocale(set.first);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

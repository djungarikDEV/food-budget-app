import 'package:flutter/material.dart';
import 'package:food_budget_app/app.dart';
import 'package:food_budget_app/data/app_config.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class SettingsSheet extends StatefulWidget {
  final AppConfig config;
  final VoidCallback onConfigChanged;

  const SettingsSheet({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TextEditingController _monthlyController;
  late TextEditingController _weeklyController;
  late TextEditingController _gistIdController;
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    final f = NumberFormat('#,###', 'hu');
    _monthlyController = TextEditingController(
        text: f.format(widget.config.monthlyAllowance));
    _weeklyController = TextEditingController(
        text: f.format(widget.config.weeklyAllowance));
    _gistIdController =
        TextEditingController(text: widget.config.gistId ?? '');
    _tokenController =
        TextEditingController(text: widget.config.githubToken ?? '');
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _weeklyController.dispose();
    _gistIdController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = FoodBudgetApp.of(context);
    final l = AppLocalizations(appState.locale);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                l.t('settings'),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // Theme toggle
            ListTile(
              leading: Icon(Icons.palette, color: theme.colorScheme.primary),
              title: Text(l.t('theme')),
              trailing: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.settings_suggest, size: 18),
                    label: Text(l.t('themeSystem'),
                        style: const TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode, size: 18),
                    label: Text(l.t('themeLight'),
                        style: const TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode, size: 18),
                    label: Text(l.t('themeDark'),
                        style: const TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {appState.themeMode},
                onSelectionChanged: (set) {
                  appState.setThemeMode(set.first);
                },
              ),
            ),
            const SizedBox(height: 8),

            // Language toggle
            ListTile(
              leading:
                  Icon(Icons.language, color: theme.colorScheme.primary),
              title: Text(l.t('language')),
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
                },
              ),
            ),
            const SizedBox(height: 8),

            // Currency selector
            ListTile(
              leading: Icon(Icons.currency_exchange,
                  color: theme.colorScheme.primary),
              title: Text(l.t('currencyLabel')),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'HUF',
                      label: Text('HUF', style: TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: 'EUR',
                      label: Text('EUR', style: TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: 'USD',
                      label: Text('USD', style: TextStyle(fontSize: 12))),
                ],
                selected: {widget.config.currency},
                onSelectionChanged: (set) {
                  setState(() => widget.config.currency = set.first);
                  widget.config.save();
                  widget.onConfigChanged();
                },
              ),
            ),

            const Divider(height: 32),

            // Allowances
            Text(l.t('allowances'),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _monthlyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.t('monthlyAllowance'),
                suffixText: 'Ft',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                final val = int.tryParse(v.replaceAll(RegExp(r'[^\d]'), ''));
                if (val != null) {
                  widget.config.monthlyAllowance = val;
                  widget.config.save();
                  widget.onConfigChanged();
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weeklyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.t('weeklyAllowance'),
                suffixText: 'Ft',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                final val = int.tryParse(v.replaceAll(RegExp(r'[^\d]'), ''));
                if (val != null) {
                  widget.config.weeklyAllowance = val;
                  widget.config.save();
                  widget.onConfigChanged();
                }
              },
            ),

            const Divider(height: 32),

            // Cloud sync
            Text(l.t('cloudSync'),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _gistIdController,
              decoration: InputDecoration(
                labelText: l.t('gistId'),
                hintText: 'abc123...',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                widget.config.gistId = v.isEmpty ? null : v;
                widget.config.save();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l.t('githubToken'),
                hintText: 'ghp_...',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                widget.config.githubToken = v.isEmpty ? null : v;
                widget.config.save();
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                final ok = await widget.config.loadFromGist();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            l.t(ok ? 'synced' : 'syncFailed'))),
                  );
                  if (ok) {
                    widget.onConfigChanged();
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.sync),
              label: Text(l.t('syncNow')),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

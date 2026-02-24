import 'package:flutter/material.dart';
import 'package:food_budget_app/l10n/localizations.dart';

class CalorieCard extends StatelessWidget {
  final AppLocalizations l;

  const CalorieCard({super.key, required this.l});

  static const _items = [
    _Food('🥣', 'breakfast', 350, 10.0, 7.0, 58.0),
    _Food('🥬', 'sprouts', 30, 3.0, 0.2, 4.0),
    _Food('🍱', 'lunch', 500, 22.0, 16.0, 55.0),
    _Food('🍽️', 'dinner', 450, 18.0, 14.0, 50.0),
    _Food('💪', 'proteinPacket', 120, 24.0, 1.5, 3.0),
    _Food('🥛', 'proteinPuttyos', 150, 15.0, 5.0, 12.0),
    _Food('🐟', 'tuna', 190, 30.0, 7.0, 0.0),
    _Food('🍌', 'banana', 110, 1.3, 0.4, 27.0),
    _Food('🧀', 'milk', 100, 12.0, 4.0, 3.0),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int totalKcal = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarb = 0;
    for (final item in _items) {
      totalKcal += item.kcal;
      totalProtein += item.protein;
      totalFat += item.fat;
      totalCarb += item.carb;
    }

    const recommendedKcal = 2600;
    const recommendedProtein = 65.0;
    final kcalPct = (totalKcal / recommendedKcal * 100).round();
    final proteinPct = (totalProtein / recommendedProtein * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l.t('calorieTitle'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(l.t('calorieSubtitle'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 16),

            // Per item
            ..._items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(l.t(item.key),
                              style: theme.textTheme.bodyMedium)),
                      Text('${item.kcal} kcal',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 50,
                        child: Text('${item.protein.round()}g P',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.blue),
                            textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                )),

            const Divider(height: 24),

            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _totalChip(context, '🔥', '$totalKcal', 'kcal'),
                _totalChip(context, '💪', '${totalProtein.round()}g', l.t('protein_short')),
                _totalChip(context, '🧈', '${totalFat.round()}g', l.t('fat_short')),
                _totalChip(context, '🌾', '${totalCarb.round()}g', l.t('carb_short')),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bars vs recommended
            Text(l.t('vsRecommended'),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 8),

            _progressRow(context, l.t('calories_label'), kcalPct,
                '$totalKcal / $recommendedKcal kcal'),
            const SizedBox(height: 8),
            _progressRow(context, l.t('protein_label'), proteinPct,
                '${totalProtein.round()} / ${recommendedProtein.round()}g'),
          ],
        ),
      ),
    );
  }

  Widget _totalChip(
      BuildContext context, String emoji, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _progressRow(
      BuildContext context, String label, int pct, String detail) {
    final theme = Theme.of(context);
    final color = pct >= 90
        ? Colors.green
        : pct >= 70
            ? Colors.orange
            : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text('$pct%',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 2),
        Text(detail,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }
}

class _Food {
  final String emoji;
  final String key;
  final int kcal;
  final double protein;
  final double fat;
  final double carb;
  const _Food(this.emoji, this.key, this.kcal, this.protein, this.fat, this.carb);
}

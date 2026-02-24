import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';

class CalorieCard extends StatelessWidget {
  final AppLocalizations l;
  final String memberId;

  const CalorieCard({super.key, required this.l, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = BudgetData.getMember(memberId);

    int totalKcal = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarb = 0;
    for (final key in BudgetData.priceKeys) {
      final n = BudgetData.nutrition[key]!;
      totalKcal += n[0].round();
      totalProtein += n[1];
      totalFat += n[2];
      totalCarb += n[3];
    }

    final recommendedKcal = member.recommendedKcal;
    final recommendedProtein = member.recommendedProtein;
    final kcalPct = (totalKcal / recommendedKcal * 100).round();
    final proteinPct = (totalProtein / recommendedProtein * 100).round();
    final warningPct = member.calorieWarningPct;

    final String gender;
    if (member.age < 18) {
      gender = member.id == 'cynthia' ? l.t('girl') : l.t('boy');
    } else {
      gender = member.id == 'cynthia' ? l.t('woman') : l.t('man');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.t('calorieTitle'),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l.t('calorieSubtitle'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 16),

            // Per item
            for (final key in BudgetData.priceKeys) ...[
              _itemRow(context, key),
              if (key != BudgetData.priceKeys.last)
                const SizedBox(height: 8),
            ],

            const Divider(height: 24),

            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _totalChip(context, '\u{1F525}', '$totalKcal', 'kcal'),
                _totalChip(context, '\u{1F4AA}', '${totalProtein.round()}g',
                    l.t('protein_short')),
                _totalChip(context, '\u{1F9C8}', '${totalFat.round()}g',
                    l.t('fat_short')),
                _totalChip(context, '\u{1F33E}', '${totalCarb.round()}g',
                    l.t('carb_short')),
              ],
            ),

            const SizedBox(height: 16),

            Text(
                l.t('vsRecommended', {
                  'age': '${member.age}',
                  'gender': gender,
                }),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 8),

            _progressRow(context, l.t('calories_label'), kcalPct,
                '$totalKcal / $recommendedKcal kcal', warningPct),
            const SizedBox(height: 8),
            _progressRow(
                context,
                l.t('protein_label'),
                proteinPct,
                '${totalProtein.round()} / ${recommendedProtein.round()}g',
                warningPct),

            if (kcalPct < warningPct) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.t('calorieWarning'),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemRow(BuildContext context, String key) {
    final theme = Theme.of(context);
    final n = BudgetData.nutrition[key]!;
    final idx = BudgetData.priceKeys.indexOf(key);
    final emoji = BudgetData.priceEmojis[idx];

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
            child:
                Text(l.t(key), style: theme.textTheme.bodyMedium)),
        Text('${n[0].round()} kcal',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text('${n[1].round()}g P',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.blue),
              textAlign: TextAlign.right),
        ),
      ],
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

  Widget _progressRow(BuildContext context, String label, int pct,
      String detail, int warningPct) {
    final theme = Theme.of(context);
    final color = pct >= 90
        ? Colors.green
        : pct >= warningPct
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

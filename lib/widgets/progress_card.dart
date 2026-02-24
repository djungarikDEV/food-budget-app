import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class ProgressCard extends StatelessWidget {
  final AppLocalizations l;
  final NumberFormat formatter;
  final MonthData data;

  const ProgressCard({
    super.key,
    required this.l,
    required this.formatter,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCurrentMonth =
        now.year == data.year && now.month == data.month;
    final dayOfMonth = isCurrentMonth ? now.day : data.totalDays;

    int weekdaysPassed = 0;
    for (int d = 1; d <= dayOfMonth; d++) {
      final date = DateTime(data.year, data.month, d);
      if (date.weekday <= 5) weekdaysPassed++;
    }

    final spent = weekdaysPassed * data.dailyTotal;
    final remaining = data.monthlyTotal - spent;
    final progress = spent / data.monthlyTotal;
    final daysLeft = data.totalDays - dayOfMonth;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l.t('progressTitle'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.9 ? Colors.red
                      : progress > 0.7 ? Colors.orange
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat(context, l.t('spent'),
                    '${formatter.format(spent)} ${l.t('huf')}', Colors.orange),
                _stat(context, l.t('remaining'),
                    '${formatter.format(remaining > 0 ? remaining : 0)} ${l.t('huf')}',
                    theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat(context, l.t('daysPassed'),
                    '$dayOfMonth / ${data.totalDays}', theme.colorScheme.outline),
                _stat(context, l.t('daysLeft'), '$daysLeft',
                    theme.colorScheme.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline)),
        Text(value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

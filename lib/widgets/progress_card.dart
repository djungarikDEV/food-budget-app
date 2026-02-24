import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/data/app_config.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class ProgressCard extends StatelessWidget {
  final AppLocalizations l;
  final NumberFormat formatter;
  final MonthInfo monthInfo;
  final AppConfig config;
  final String memberId;

  const ProgressCard({
    super.key,
    required this.l,
    required this.formatter,
    required this.monthInfo,
    required this.config,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCurrentMonth =
        now.year == monthInfo.year && now.month == monthInfo.month;
    final dayOfMonth = isCurrentMonth ? now.day : monthInfo.totalDays;

    int weekdaysPassed = 0;
    for (int d = 1; d <= dayOfMonth; d++) {
      final date = DateTime(monthInfo.year, monthInfo.month, d);
      if (date.weekday <= 5) weekdaysPassed++;
    }

    final dailyCovered = config.coveredDailyTotal(memberId, monthInfo.month);
    final spent = weekdaysPassed * dailyCovered;
    final budget = config.monthlyAllowance;
    final remaining = budget - spent;
    final progress = spent / budget;
    final daysLeft = monthInfo.totalDays - dayOfMonth;

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
                  progress > 0.9
                      ? Colors.red
                      : progress > 0.7
                          ? Colors.orange
                          : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat(context, l.t('spent'),
                    config.formatPrice(spent, formatter), Colors.orange,
                    CrossAxisAlignment.start),
                _stat(
                    context,
                    l.t('remaining'),
                    config.formatPrice(
                        remaining > 0 ? remaining : 0, formatter),
                    theme.colorScheme.primary,
                    CrossAxisAlignment.end),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat(
                    context,
                    l.t('daysPassed'),
                    '$dayOfMonth / ${monthInfo.totalDays}',
                    theme.colorScheme.outline,
                    CrossAxisAlignment.start),
                _stat(context, l.t('daysLeft'), '$daysLeft',
                    theme.colorScheme.outline, CrossAxisAlignment.end),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color,
      CrossAxisAlignment alignment) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignment,
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

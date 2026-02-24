import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/data/app_config.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final AppLocalizations l;
  final NumberFormat formatter;
  final MonthInfo monthInfo;
  final AppConfig config;
  final String memberId;

  const SummaryCard({
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
    final daily = config.dailyTotal(memberId, monthInfo.month);
    final monthly = config.monthlyTotal(memberId, monthInfo.month);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l.t('summaryTitle'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildRow(
                context,
                '\u{1F4C5}',
                l.t('summaryWeekdays', {
                  'count': '${monthInfo.weekdayCount}',
                  'cost': config.formatPrice(daily, formatter),
                })),
            const SizedBox(height: 12),
            _buildRow(
                context,
                '\u{1F37D}\u{FE0F}',
                l.t('summaryWeekends',
                    {'name': BudgetData.fatherName})),
            const SizedBox(height: 12),
            _buildRow(
                context,
                '\u{1F4CC}',
                l.t('weekendNote',
                    {'name': BudgetData.fatherName})),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(l.t('summaryTotal'),
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer)),
                  const SizedBox(height: 4),
                  Text(
                    config.formatPrice(monthly, formatter),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String emoji, String text) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}

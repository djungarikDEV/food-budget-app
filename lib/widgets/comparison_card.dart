import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class ComparisonCard extends StatelessWidget {
  final AppLocalizations l;
  final NumberFormat formatter;

  const ComparisonCard({super.key, required this.l, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final march = BudgetData.months[3]!;
    final sparDaily = march.dailyTotal;
    const canteenDaily = 7000;
    const restaurantDaily = 12000;
    const deliveryDaily = 9500;

    final sparMonthly = march.monthlyTotal;
    final canteenMonthly = canteenDaily * march.weekdayCount;
    final restaurantMonthly = restaurantDaily * march.weekdayCount;
    final deliveryMonthly = deliveryDaily * march.weekdayCount;

    final maxVal = restaurantMonthly.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.t('comparisonTitle'),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l.t('comparisonSubtitle'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 20),

            _bar(context, '🛒 Spar', sparDaily, sparMonthly, maxVal,
                Colors.green, true),
            const SizedBox(height: 12),
            _bar(context, '🍽️ ${l.t('canteen')}', canteenDaily,
                canteenMonthly, maxVal, Colors.orange, false),
            const SizedBox(height: 12),
            _bar(context, '🚗 ${l.t('delivery')}', deliveryDaily,
                deliveryMonthly, maxVal, Colors.red.shade300, false),
            const SizedBox(height: 12),
            _bar(context, '🍷 ${l.t('restaurant')}', restaurantDaily,
                restaurantMonthly, maxVal, Colors.red, false),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.t('savingsText', {
                        'restaurant': formatter.format(restaurantMonthly - sparMonthly),
                        'canteen': formatter.format(canteenMonthly - sparMonthly),
                      }),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _bar(BuildContext context, String label, int daily, int monthly,
      double maxVal, Color color, bool highlight) {
    final theme = Theme.of(context);
    final pct = monthly / maxVal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
            Text(
              '${formatter.format(daily)} Ft/${l.t('dayShort')} → ${formatter.format(monthly)} Ft/${l.t('monthShort')}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: highlight ? color : theme.colorScheme.outline),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: highlight ? 10 : 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class DailyBreakdownCard extends StatelessWidget {
  final AppLocalizations l;
  final NumberFormat formatter;
  final MonthData data;
  final ValueChanged<int>? onEditPrice;

  const DailyBreakdownCard({
    super.key,
    required this.l,
    required this.formatter,
    required this.data,
    this.onEditPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prices = data.prices;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.t('dailyBreakdown'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(l.t('shoppingAt'),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline)),
                const Spacer(),
                if (onEditPrice != null)
                  Text(l.t('tapToEdit'),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < BudgetData.priceKeys.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              _buildItem(
                context,
                BudgetData.priceEmojis[i],
                l.t(BudgetData.priceKeys[i]),
                '~${formatter.format(prices[i])} ${l.t('huf')}',
                onEditPrice != null ? () => onEditPrice!(i) : null,
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.t('dailyTotal'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '~${formatter.format(data.dailyTotal)} ${l.t('huf')}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String emoji, String name,
      String price, VoidCallback? onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),
          Text(price,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: theme.colorScheme.outline),
          ],
        ],
      ),
    );
  }
}

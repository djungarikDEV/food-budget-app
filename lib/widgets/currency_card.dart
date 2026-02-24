import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class CurrencyCard extends StatelessWidget {
  final AppLocalizations l;
  final NumberFormat formatter;
  final MonthData data;

  const CurrencyCard({
    super.key,
    required this.l,
    required this.formatter,
    required this.data,
  });

  static const double hufToEur = 0.0025;
  static const double hufToUsd = 0.0027;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthly = data.monthlyTotal;
    final daily = data.dailyTotal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.currency_exchange, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l.t('currencyTitle'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(l.t('currencyApprox'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 16),
            _row(context, '🇭🇺', l.t('monthlyHuf'),
                '${formatter.format(monthly)} Ft'),
            const Divider(height: 20),
            _row(context, '🇪🇺', l.t('monthlyEur'),
                '€${(monthly * hufToEur).toStringAsFixed(0)}'),
            const Divider(height: 20),
            _row(context, '🇺🇸', l.t('monthlyUsd'),
                '\$${(monthly * hufToUsd).toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l.t('dailyEquiv', {
                  'eur': (daily * hufToEur).toStringAsFixed(1),
                  'usd': (daily * hufToUsd).toStringAsFixed(1),
                }),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String flag, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyLarge),
        ]),
        Text(value,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

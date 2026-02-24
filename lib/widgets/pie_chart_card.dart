import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';

class PieChartCard extends StatelessWidget {
  final AppLocalizations l;
  final MonthData data;

  const PieChartCard({super.key, required this.l, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      Colors.green, Colors.orange, Colors.deepPurple,
      Colors.blue, Colors.pink, Colors.teal,
      Colors.amber, Colors.yellow.shade700, Colors.cyan,
    ];

    final items = List.generate(BudgetData.priceKeys.length, (i) => _Item(
      l.t(BudgetData.priceKeys[i]), data.prices[i], colors[i],
    ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l.t('chartTitle'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: items.map((item) {
                    final pct = (item.value / data.dailyTotal * 100).round();
                    return PieChartSectionData(
                      value: item.value.toDouble(),
                      title: '$pct%',
                      color: item.color,
                      radius: 55,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: items.map((item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12,
                      decoration: BoxDecoration(
                          color: item.color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(item.label, style: theme.textTheme.bodySmall),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final String label;
  final int value;
  final Color color;
  _Item(this.label, this.value, this.color);
}

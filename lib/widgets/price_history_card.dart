import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class PriceHistoryCard extends StatelessWidget {
  final AppLocalizations l;
  final NumberFormat formatter;

  const PriceHistoryCard({super.key, required this.l, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = [
      BudgetData.months[3]!,
      BudgetData.months[4]!,
      BudgetData.months[5]!,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l.t('priceHistory'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (months
                              .map((m) => m.monthlyTotal)
                              .reduce((a, b) => a > b ? a : b) *
                          1.15)
                      .toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIdx, rod, rodIdx) {
                        return BarTooltipItem(
                          '${formatter.format(rod.toY.round())} Ft',
                          TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = ['Már.', 'Ápr.', 'Máj.'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[value.toInt()],
                                style: theme.textTheme.bodySmall),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(3, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: months[i].monthlyTotal.toDouble(),
                          color: theme.colorScheme.primary,
                          width: 32,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: months
                  .map((m) => Text(
                        '${formatter.format(m.monthlyTotal)} Ft',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';

class PieChartCard extends StatefulWidget {
  final AppLocalizations l;
  final Map<String, int> prices;

  const PieChartCard({super.key, required this.l, required this.prices});

  @override
  State<PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<PieChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.deepPurple,
      Colors.blue,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.yellow.shade700,
      Colors.cyan,
    ];

    final total = widget.prices.values.fold(0, (s, p) => s + p);
    final items = List.generate(BudgetData.priceKeys.length, (i) {
      final key = BudgetData.priceKeys[i];
      return _Item(widget.l.t(key), widget.prices[key] ?? 0, colors[i]);
    });

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
                Text(widget.l.t('chartTitle'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(items.length, (i) {
                    final item = items[i];
                    final isTouched = i == _touchedIndex;
                    final pct =
                        total > 0 ? (item.value / total * 100).round() : 0;
                    return PieChartSectionData(
                      value: item.value.toDouble(),
                      title: isTouched ? item.label : '$pct%',
                      color: item.color,
                      radius: isTouched ? 65 : 55,
                      titleStyle: TextStyle(
                        fontSize: isTouched ? 12 : 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: isTouched ? 0.55 : 0.5,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: items
                  .map((item) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(item.label,
                              style: theme.textTheme.bodySmall),
                        ],
                      ))
                  .toList(),
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

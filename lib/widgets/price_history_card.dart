import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/data/app_config.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class PriceHistoryCard extends StatefulWidget {
  final AppLocalizations l;
  final NumberFormat formatter;
  final AppConfig config;

  const PriceHistoryCard({
    super.key,
    required this.l,
    required this.formatter,
    required this.config,
  });

  @override
  State<PriceHistoryCard> createState() => _PriceHistoryCardState();
}

class _PriceHistoryCardState extends State<PriceHistoryCard> {
  String _view = 'monthly'; // daily, weekly, monthly

  static const _memberColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = widget.l;

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
                Expanded(
                  child: Text(l.t('priceHistory'),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // View toggle
            Center(
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: 'daily',
                      label: Text(l.t('viewDaily'),
                          style: const TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: 'weekly',
                      label: Text(l.t('viewWeekly'),
                          style: const TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: 'monthly',
                      label: Text(l.t('viewMonthly'),
                          style: const TextStyle(fontSize: 12))),
                ],
                selected: {_view},
                onSelectionChanged: (s) => setState(() => _view = s.first),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: _buildChart(theme),
            ),
            const SizedBox(height: 16),

            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: List.generate(BudgetData.members.length, (i) {
                final member = BudgetData.members[i];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: _memberColors[i],
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 6),
                    Text(member.displayName,
                        style: theme.textTheme.bodySmall),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    switch (_view) {
      case 'daily':
        return _buildDailyChart(theme);
      case 'weekly':
        return _buildWeeklyChart(theme);
      default:
        return _buildMonthlyChart(theme);
    }
  }

  BarChart _buildDailyChart(ThemeData theme) {
    // Show Mon-Fri daily totals for each member
    final weekdayLabels = [
      widget.l.t('mon'),
      widget.l.t('tue'),
      widget.l.t('wed'),
      widget.l.t('thu'),
      widget.l.t('fri'),
    ];

    double maxY = 0;
    final groups = List.generate(5, (dayIdx) {
      final weekday = dayIdx + 1;
      final rods = List.generate(BudgetData.members.length, (mi) {
        final member = BudgetData.members[mi];
        // Average across all months for this weekday
        double avg = 0;
        for (final month in BudgetData.months.keys) {
          avg += widget.config
              .dailyTotal(member.id, month, weekday)
              .toDouble();
        }
        avg /= BudgetData.months.length;
        if (avg > maxY) maxY = avg;
        return BarChartRodData(
          toY: avg,
          color: _memberColors[mi],
          width: 8,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
          ),
        );
      });
      return BarChartGroupData(x: dayIdx, barRods: rods);
    });

    return BarChart(_barData(groups, maxY * 1.15, (value) {
      if (value.toInt() < weekdayLabels.length) {
        return weekdayLabels[value.toInt()];
      }
      return '';
    }, theme));
  }

  BarChart _buildWeeklyChart(ThemeData theme) {
    // Show 4 weeks average for each member
    double maxY = 0;
    final groups = List.generate(4, (weekIdx) {
      final rods = List.generate(BudgetData.members.length, (mi) {
        final member = BudgetData.members[mi];
        double avg = 0;
        for (final month in BudgetData.months.keys) {
          avg += widget.config.dailyTotal(member.id, month).toDouble() * 5;
        }
        avg /= BudgetData.months.length;
        if (avg > maxY) maxY = avg;
        return BarChartRodData(
          toY: avg,
          color: _memberColors[mi],
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
          ),
        );
      });
      return BarChartGroupData(x: weekIdx, barRods: rods);
    });

    return BarChart(_barData(groups, maxY * 1.15, (value) {
      return 'W${value.toInt() + 1}';
    }, theme));
  }

  BarChart _buildMonthlyChart(ThemeData theme) {
    final monthKeys = BudgetData.months.keys.toList()..sort();
    double maxY = 0;

    final groups = List.generate(monthKeys.length, (mIdx) {
      final month = monthKeys[mIdx];
      final rods = List.generate(BudgetData.members.length, (mi) {
        final member = BudgetData.members[mi];
        final total =
            widget.config.monthlyTotal(member.id, month).toDouble();
        if (total > maxY) maxY = total;
        return BarChartRodData(
          toY: total,
          color: _memberColors[mi],
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        );
      });
      return BarChartGroupData(x: mIdx, barRods: rods);
    });

    final monthLabels = monthKeys.map((m) {
      final isHu = widget.l.t('appTitle').contains('Havi');
      switch (m) {
        case 3:
          return isHu ? 'M\u00E1r.' : 'Mar';
        case 4:
          return isHu ? '\u00C1pr.' : 'Apr';
        case 5:
          return isHu ? 'M\u00E1j.' : 'May';
        default:
          return '$m';
      }
    }).toList();

    return BarChart(_barData(groups, maxY * 1.15, (value) {
      final idx = value.toInt();
      if (idx < monthLabels.length) return monthLabels[idx];
      return '';
    }, theme));
  }

  BarChartData _barData(
    List<BarChartGroupData> groups,
    double maxY,
    String Function(double) bottomTitleFn,
    ThemeData theme,
  ) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 8,
          getTooltipItem: (group, groupIdx, rod, rodIdx) {
            final member = BudgetData.members[rodIdx];
            return BarTooltipItem(
              '${member.displayName}\n${widget.config.formatPrice(rod.toY.round(), widget.formatter)}',
              TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 11,
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
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(bottomTitleFn(value),
                    style: theme.textTheme.bodySmall),
              );
            },
          ),
        ),
        leftTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: groups,
    );
  }
}

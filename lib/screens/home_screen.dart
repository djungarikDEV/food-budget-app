import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:food_budget_app/widgets/budget_card.dart';
import 'package:food_budget_app/widgets/daily_breakdown_card.dart';
import 'package:food_budget_app/widgets/summary_card.dart';
import 'package:food_budget_app/widgets/why_card.dart';
import 'package:food_budget_app/widgets/progress_card.dart';
import 'package:food_budget_app/widgets/pie_chart_card.dart';
import 'package:food_budget_app/widgets/currency_card.dart';
import 'package:food_budget_app/widgets/share_button.dart';
import 'package:food_budget_app/widgets/tip_card.dart';
import 'package:food_budget_app/widgets/calorie_card.dart';
import 'package:food_budget_app/widgets/comparison_card.dart';
import 'package:food_budget_app/widgets/month_selector.dart';
import 'package:food_budget_app/widgets/price_history_card.dart';
import 'package:food_budget_app/widgets/settings_sheet.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String locale;

  const HomeScreen({super.key, required this.locale});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  int _selectedMonth = 3;

  MonthData get _data => BudgetData.months[_selectedMonth]!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animatedCard(int index, Widget child) {
    final start = (index * 0.06).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  void _editPrice(int index) {
    final l = AppLocalizations(widget.locale);
    final currentPrice = _data.prices[index];
    final controller = TextEditingController(text: '$currentPrice');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('editPrice')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.t(BudgetData.priceKeys[index]),
            suffixText: 'Ft',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                setState(() => _data.setPrice(index, val));
              }
              Navigator.pop(ctx);
            },
            child: Text(l.t('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(widget.locale);
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###', 'hu');
    final data = _data;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('appTitle')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l.t('settings'),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const SettingsSheet(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Month selector
            _animatedCard(0, MonthSelector(
              selectedMonth: _selectedMonth,
              onChanged: (m) => setState(() => _selectedMonth = m),
              l: l,
            )),

            const SizedBox(height: 12),

            // Header
            _animatedCard(1, Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu, size: 48,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(height: 8),
                    Text(l.t('month_$_selectedMonth'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(l.t('periodFor_$_selectedMonth'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer)),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 16),

            // Progress
            _animatedCard(2, ProgressCard(l: l, formatter: formatter, data: data)),
            const SizedBox(height: 16),

            // Overview cards
            _animatedCard(3, Row(
              children: [
                Expanded(child: BudgetCard(
                  icon: Icons.work,
                  label: l.t('weekdays'),
                  value: l.t('weekdayCount', {'count': '${data.weekdayCount}'}),
                  color: theme.colorScheme.secondaryContainer,
                  textColor: theme.colorScheme.onSecondaryContainer,
                )),
                const SizedBox(width: 12),
                Expanded(child: BudgetCard(
                  icon: Icons.weekend,
                  label: l.t('weekends'),
                  value: l.t('weekendCount', {'count': '${data.weekendCount}'}),
                  subtitle: l.t('paidByFather', {'name': BudgetData.fatherName}),
                  color: theme.colorScheme.tertiaryContainer,
                  textColor: theme.colorScheme.onTertiaryContainer,
                )),
              ],
            )),
            const SizedBox(height: 16),

            // Daily breakdown (editable)
            _animatedCard(4, DailyBreakdownCard(
              l: l, formatter: formatter, data: data,
              onEditPrice: _editPrice,
            )),
            const SizedBox(height: 16),

            // Calorie counter
            _animatedCard(5, CalorieCard(l: l)),
            const SizedBox(height: 16),

            // Pie chart
            _animatedCard(6, PieChartCard(l: l, data: data)),
            const SizedBox(height: 16),

            // Summary
            _animatedCard(7, SummaryCard(l: l, formatter: formatter, data: data)),
            const SizedBox(height: 16),

            // Price comparison
            _animatedCard(8, ComparisonCard(l: l, formatter: formatter)),
            const SizedBox(height: 16),

            // Currency
            _animatedCard(9, CurrencyCard(l: l, formatter: formatter, data: data)),
            const SizedBox(height: 16),

            // Price history chart
            _animatedCard(10, PriceHistoryCard(l: l, formatter: formatter)),
            const SizedBox(height: 16),

            // Why explanation
            _animatedCard(11, WhyCard(l: l)),
            const SizedBox(height: 16),

            // Tip
            _animatedCard(12, TipCard(l: l)),
            const SizedBox(height: 16),

            // Share
            _animatedCard(13, ShareButton(l: l, data: data)),
            const SizedBox(height: 16),

            // Thank you
            _animatedCard(14, Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l.t('thankYou', {'name': BudgetData.fatherName}),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

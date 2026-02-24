import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/data/app_config.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:food_budget_app/widgets/budget_card.dart';
import 'package:food_budget_app/widgets/daily_breakdown_card.dart';
import 'package:food_budget_app/widgets/summary_card.dart';
import 'package:food_budget_app/widgets/progress_card.dart';
import 'package:food_budget_app/widgets/pie_chart_card.dart';
import 'package:food_budget_app/widgets/share_button.dart';
import 'package:food_budget_app/widgets/calorie_card.dart';
import 'package:food_budget_app/widgets/month_selector.dart';
import 'package:food_budget_app/widgets/price_history_card.dart';
import 'package:food_budget_app/widgets/settings_sheet.dart';
import 'package:food_budget_app/widgets/member_selector.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String locale;

  const HomeScreen({super.key, required this.locale});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  int _selectedMonth = 3;
  String _selectedMemberId = 'maxim';
  AppConfig? _config;

  MonthInfo get _monthInfo => BudgetData.months[_selectedMonth]!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await AppConfig.load();
    setState(() => _config = config);
  }

  void _onConfigChanged() {
    setState(() {});
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

  int _getColumnCount(double width) {
    if (width > 1200) return 4;
    if (width > 900) return 3;
    if (width > 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(widget.locale);
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###', 'hu');

    if (_config == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final config = _config!;
    final monthInfo = _monthInfo;
    final prices = config.getBasePrices(_selectedMemberId, _selectedMonth);

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
              isScrollControlled: true,
              builder: (_) => SettingsSheet(
                config: config,
                onConfigChanged: _onConfigChanged,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _getColumnCount(constraints.maxWidth);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Member selector (always full width)
                _animatedCard(
                    0,
                    MemberSelector(
                      selectedMemberId: _selectedMemberId,
                      onChanged: (id) =>
                          setState(() => _selectedMemberId = id),
                    )),
                const SizedBox(height: 12),

                // Month selector (always full width)
                _animatedCard(
                    1,
                    MonthSelector(
                      selectedMonth: _selectedMonth,
                      onChanged: (m) =>
                          setState(() => _selectedMonth = m),
                      l: l,
                    )),
                const SizedBox(height: 12),

                // Header (always full width)
                _animatedCard(
                    2,
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.restaurant_menu,
                                size: 48,
                                color: theme
                                    .colorScheme.onPrimaryContainer),
                            const SizedBox(height: 8),
                            Text(
                                '${BudgetData.getMember(_selectedMemberId).displayName} \u2014 ${l.t('month_$_selectedMonth')}',
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                  color: theme
                                      .colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 4),
                            Text(
                                l.t('periodFor_$_selectedMonth'),
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(
                                        color: theme.colorScheme
                                            .onPrimaryContainer)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),

                // Grid of cards
                _buildResponsiveGrid(columns, l, formatter, config,
                    monthInfo, prices),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveGrid(
    int columns,
    AppLocalizations l,
    NumberFormat formatter,
    AppConfig config,
    MonthInfo monthInfo,
    Map<String, int> prices,
  ) {
    final theme = Theme.of(context);

    final cards = <Widget>[
      // Progress
      _animatedCard(
          3,
          ProgressCard(
            l: l,
            formatter: formatter,
            monthInfo: monthInfo,
            config: config,
            memberId: _selectedMemberId,
          )),

      // Overview cards (weekday/weekend)
      _animatedCard(
          4,
          Row(
            children: [
              Expanded(
                  child: BudgetCard(
                icon: Icons.work,
                label: l.t('weekdays'),
                value: l.t('weekdayCount',
                    {'count': '${monthInfo.weekdayCount}'}),
                color: theme.colorScheme.secondaryContainer,
                textColor: theme.colorScheme.onSecondaryContainer,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: BudgetCard(
                icon: Icons.weekend,
                label: l.t('weekends'),
                value: l.t('weekendCount',
                    {'count': '${monthInfo.weekendCount}'}),
                subtitle: l.t('paidByFather',
                    {'name': BudgetData.fatherName}),
                color: theme.colorScheme.tertiaryContainer,
                textColor: theme.colorScheme.onTertiaryContainer,
              )),
            ],
          )),

      // Daily breakdown
      _animatedCard(
          5,
          DailyBreakdownCard(
            l: l,
            formatter: formatter,
            config: config,
            memberId: _selectedMemberId,
            month: _selectedMonth,
            onConfigChanged: _onConfigChanged,
          )),

      // Calories
      _animatedCard(
          6,
          CalorieCard(l: l, memberId: _selectedMemberId)),

      // Pie chart
      _animatedCard(
          7, PieChartCard(l: l, prices: prices)),

      // Summary
      _animatedCard(
          8,
          SummaryCard(
            l: l,
            formatter: formatter,
            monthInfo: monthInfo,
            config: config,
            memberId: _selectedMemberId,
          )),

      // Price history
      _animatedCard(
          9,
          PriceHistoryCard(
            l: l,
            formatter: formatter,
            config: config,
          )),

      // Share
      _animatedCard(
          10,
          ShareButton(
            l: l,
            config: config,
            memberId: _selectedMemberId,
            month: _selectedMonth,
          )),
    ];

    if (columns <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards
            .expand((c) => [c, const SizedBox(height: 16)])
            .toList(),
      );
    }

    // Distribute cards across columns (masonry style)
    final columnLists = List.generate(columns, (_) => <Widget>[]);
    for (int i = 0; i < cards.length; i++) {
      columnLists[i % columns].add(
        Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: cards[i]),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < columns; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: columnLists[i],
            ),
          ),
        ],
      ],
    );
  }
}

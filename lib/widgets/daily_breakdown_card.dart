import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/data/app_config.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class DailyBreakdownCard extends StatefulWidget {
  final AppLocalizations l;
  final NumberFormat formatter;
  final AppConfig config;
  final String memberId;
  final int month;
  final VoidCallback onConfigChanged;

  const DailyBreakdownCard({
    super.key,
    required this.l,
    required this.formatter,
    required this.config,
    required this.memberId,
    required this.month,
    required this.onConfigChanged,
  });

  @override
  State<DailyBreakdownCard> createState() => _DailyBreakdownCardState();
}

class _DailyBreakdownCardState extends State<DailyBreakdownCard> {
  int? _selectedWeekday; // null = base, 1-5 = Mon-Fri

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = widget.l;
    final prices = widget.config
        .getEffectivePrices(widget.memberId, widget.month, _selectedWeekday);
    final total = prices.values.fold(0, (s, p) => s + p);

    final weekdayLabels = [
      l.t('base'),
      l.t('mon'),
      l.t('tue'),
      l.t('wed'),
      l.t('thu'),
      l.t('fri'),
    ];

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
                Text(l.t('tapToEdit'),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 12),

            // Weekday tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(6, (i) {
                  final weekday = i == 0 ? null : i;
                  final selected = _selectedWeekday == weekday;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(weekdayLabels[i],
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedWeekday = weekday),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            for (int i = 0; i < BudgetData.priceKeys.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              _buildItem(context, i, prices),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.t('dailyTotal'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.config.formatPrice(total, widget.formatter),
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

  Widget _buildItem(
      BuildContext context, int index, Map<String, int> prices) {
    final theme = Theme.of(context);
    final key = BudgetData.priceKeys[index];
    final emoji = BudgetData.priceEmojis[index];
    final name = widget.l.t(key);
    final price = prices[key] ?? 0;
    final uncovered = widget.config.isUncovered(widget.memberId, key);

    // Check if this item is at base price or overridden
    final isBase = _selectedWeekday == null ||
        widget.config
            .isBasePrice(widget.memberId, widget.month, _selectedWeekday!, key);

    return InkWell(
      onTap: () => _editPrice(index, key, price),
      onLongPress: () => _toggleCovered(key),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            !isBase ? FontWeight.bold : FontWeight.normal,
                      )),
                  Row(
                    children: [
                      if (!isBase && _selectedWeekday != null)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(widget.l.t('overriddenItem'),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme
                                      .onTertiaryContainer)),
                        ),
                      if (isBase && _selectedWeekday != null)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(widget.l.t('baseMenuItem'),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.outline)),
                        ),
                      if (uncovered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color:
                                    Colors.orange.withValues(alpha: 0.4)),
                          ),
                          child: Text(widget.l.t('uncovered'),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.orange)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              widget.config.formatPrice(price, widget.formatter),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    uncovered ? Colors.orange : null,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  void _editPrice(int index, String key, int currentPrice) {
    final l = widget.l;
    final controller = TextEditingController(text: '$currentPrice');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('editPrice')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.t(key),
                suffixText: 'Ft',
              ),
            ),
            if (_selectedWeekday != null &&
                !widget.config.isBasePrice(
                    widget.memberId, widget.month, _selectedWeekday!, key))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  onPressed: () {
                    widget.config.resetWeekdayPrice(
                        widget.memberId, widget.month, _selectedWeekday!, key);
                    widget.config.save();
                    widget.onConfigChanged();
                    setState(() {});
                    Navigator.pop(ctx);
                  },
                  child: Text(l.t('resetToBase')),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 0) {
                if (_selectedWeekday == null) {
                  widget.config.setBasePrice(
                      widget.memberId, widget.month, key, val);
                } else {
                  widget.config.setWeekdayPrice(
                      widget.memberId, widget.month, _selectedWeekday!, key,
                      val);
                }
                widget.config.save();
                widget.onConfigChanged();
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: Text(l.t('save')),
          ),
        ],
      ),
    );
  }

  void _toggleCovered(String key) {
    widget.config.toggleUncovered(widget.memberId, key);
    widget.config.save();
    widget.onConfigChanged();
    setState(() {});
  }
}

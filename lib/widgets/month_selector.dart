import 'package:flutter/material.dart';
import 'package:food_budget_app/l10n/localizations.dart';

class MonthSelector extends StatelessWidget {
  final int selectedMonth; // 3, 4, 5
  final ValueChanged<int> onChanged;
  final AppLocalizations l;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed:
              selectedMonth > 3 ? () => onChanged(selectedMonth - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0 && selectedMonth < 5) {
                onChanged(selectedMonth + 1);
              } else if (details.primaryVelocity! > 0 && selectedMonth > 3) {
                onChanged(selectedMonth - 1);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l.t('month_$selectedMonth'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed:
              selectedMonth < 5 ? () => onChanged(selectedMonth + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

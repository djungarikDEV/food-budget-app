import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class ShareButton extends StatelessWidget {
  final AppLocalizations l;
  final MonthData data;

  const ShareButton({super.key, required this.l, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _copy(context),
        icon: const Icon(Icons.copy),
        label: Text(l.t('shareButton')),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: theme.textTheme.titleSmall,
        ),
      ),
    );
  }

  void _copy(BuildContext context) {
    final f = NumberFormat('#,###', 'hu');
    final prices = data.prices;
    final lines = <String>[];
    for (int i = 0; i < BudgetData.priceKeys.length; i++) {
      lines.add(
          '  ${BudgetData.priceEmojis[i]} ${l.t(BudgetData.priceKeys[i])}: ~${f.format(prices[i])} Ft');
    }
    final text = '''
${l.t('appTitle')} — ${l.t('month_${data.month}')}
${'═' * 35}

${l.t('dailyBreakdown')}:
${lines.join('\n')}

${l.t('dailyTotal')}: ~${f.format(data.dailyTotal)} Ft
${l.t('weekdays')}: ${data.weekdayCount} ${l.t('daysLabel')}
${l.t('summaryTotal')}: ${f.format(data.monthlyTotal)} Ft

${l.t('weekendNote', {'name': BudgetData.fatherName})}

${l.t('thankYou', {'name': BudgetData.fatherName})}
''';
    Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.t('copied'))));
    }
  }
}

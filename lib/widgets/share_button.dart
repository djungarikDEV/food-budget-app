import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/data/app_config.dart';
import 'package:food_budget_app/l10n/localizations.dart';
import 'package:intl/intl.dart';

class ShareButton extends StatelessWidget {
  final AppLocalizations l;
  final AppConfig config;
  final String memberId;
  final int month;

  const ShareButton({
    super.key,
    required this.l,
    required this.config,
    required this.memberId,
    required this.month,
  });

  String _buildText() {
    final f = NumberFormat('#,###', 'hu');
    final prices = config.getBasePrices(memberId, month);
    final member = BudgetData.getMember(memberId);
    final monthInfo = BudgetData.months[month]!;
    final daily = config.dailyTotal(memberId, month);
    final monthly = config.monthlyTotal(memberId, month);

    final lines = <String>[];
    for (int i = 0; i < BudgetData.priceKeys.length; i++) {
      final key = BudgetData.priceKeys[i];
      final price = prices[key] ?? 0;
      final uncovered = config.isUncovered(memberId, key);
      lines.add(
          '  ${BudgetData.priceEmojis[i]} ${l.t(key)}: ~${f.format(price)} Ft${uncovered ? ' (${l.t('uncovered')})' : ''}');
    }
    return '''
${l.t('appTitle')} \u2014 ${member.displayName} \u2014 ${l.t('month_$month')}
${'=' * 40}

${l.t('dailyBreakdown')}:
${lines.join('\n')}

${l.t('dailyTotal')}: ~${f.format(daily)} Ft
${l.t('weekdays')}: ${monthInfo.weekdayCount} ${l.t('daysLabel')}
${l.t('summaryTotal')}: ${f.format(monthly)} Ft

${l.t('weekendNote', {'name': BudgetData.fatherName})}
''';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _showPreview(context),
        icon: const Icon(Icons.copy),
        label: Text(l.t('shareButton')),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: theme.textTheme.titleSmall,
        ),
      ),
    );
  }

  void _showPreview(BuildContext context) {
    final theme = Theme.of(context);
    final text = _buildText();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('copyPreviewTitle')),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              text,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.t('cancel')),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.t('copied'))));
              }
            },
            icon: const Icon(Icons.copy, size: 16),
            label: Text(l.t('copyConfirm')),
          ),
        ],
      ),
    );
  }
}

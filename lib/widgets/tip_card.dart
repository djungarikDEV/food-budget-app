import 'dart:math';
import 'package:flutter/material.dart';
import 'package:food_budget_app/l10n/localizations.dart';

class TipCard extends StatefulWidget {
  final AppLocalizations l;

  const TipCard({super.key, required this.l});

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  late int _currentTip;

  @override
  void initState() {
    super.initState();
    _currentTip = Random().nextInt(8);
  }

  void _nextTip() {
    setState(() {
      _currentTip = (_currentTip + 1) % 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tip = widget.l.t('tip$_currentTip');

    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: InkWell(
        onTap: _nextTip,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb,
                      color: theme.colorScheme.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    widget.l.t('tipTitle'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.touch_app,
                      size: 16,
                      color: theme.colorScheme.onTertiaryContainer
                          .withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tip,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

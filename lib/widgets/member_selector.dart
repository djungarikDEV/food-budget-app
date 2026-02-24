import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';

class MemberSelector extends StatelessWidget {
  final String selectedMemberId;
  final ValueChanged<String> onChanged;

  const MemberSelector({
    super.key,
    required this.selectedMemberId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: BudgetData.members.map((member) {
          final selected = member.id == selectedMemberId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(member.displayName),
              selected: selected,
              onSelected: (_) => onChanged(member.id),
              avatar: Icon(
                member.id == 'dad' ? Icons.person : Icons.child_care,
                size: 18,
                color: selected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.outline,
              ),
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:food_budget_app/data/budget_data.dart';
import 'package:food_budget_app/data/app_config.dart';

class ProfileSelectionScreen extends StatefulWidget {
  final ValueChanged<String> onProfileSelected;

  const ProfileSelectionScreen({super.key, required this.onProfileSelected});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedId;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selectedId == null) return;
    await AppConfig.saveSelectedProfile(_selectedId!);
    widget.onProfileSelected(_selectedId!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Te ki vagy?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: BudgetData.members.map((member) {
                        return ButtonSegment<String>(
                          value: member.id,
                          label: Text(member.displayName),
                          icon: Icon(
                            member.id == 'dad'
                                ? Icons.person
                                : Icons.child_care,
                          ),
                        );
                      }).toList(),
                      selected: _selectedId != null ? {_selectedId!} : {},
                      onSelectionChanged: (selected) {
                        setState(() => _selectedId = selected.first);
                      },
                      emptySelectionAllowed: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedOpacity(
                    opacity: _selectedId != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: FilledButton.icon(
                      onPressed: _selectedId != null ? _confirm : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Tovabb'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

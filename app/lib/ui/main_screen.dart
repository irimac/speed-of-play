import 'package:flutter/material.dart';

import '../data/models.dart';
import 'widgets/recipe_renderer/recipe_actions.dart';
import 'widgets/recipe_renderer/recipe_renderer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.preset,
    required this.onPresetChanged,
  });

  static const routeName = '/main';

  final SessionPreset preset;
  final ValueChanged<SessionPreset> onPresetChanged;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late SessionPreset _preset;

  @override
  void initState() {
    super.initState();
    _preset = widget.preset;
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preset != widget.preset) {
      _preset = widget.preset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final configText =
        'Rounds: ${_preset.rounds} | Duration: ${_preset.roundDurationSec}s | Numbers: ${_preset.numberMin}-${_preset.numberMax}';
    return Scaffold(
      body: SafeArea(
        child: RecipeRenderer(
          screen: 'main',
          textOverrides: {
            'config': configText,
          },
          onAction: (action) => RecipeActions.handle(
            context,
            action,
            preset: _preset,
            onPresetChanged: (p) {
              widget.onPresetChanged(p);
              setState(() => _preset = p);
            },
          ),
        ),
      ),
    );
  }
}

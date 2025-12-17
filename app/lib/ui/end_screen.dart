import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../services/history_repository.dart';
import 'widgets/recipe_renderer/recipe_actions.dart';
import 'widgets/recipe_renderer/recipe_renderer.dart';
import 'main_screen.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key, required this.result});

  static const routeName = '/end';

  final SessionResult? result;

  @override
  Widget build(BuildContext context) {
    final summary = _buildSummary();
    return Scaffold(
      body: SafeArea(
        child: RecipeRenderer(
          screen: 'summary',
          textOverrides: summary,
          onAction: (action) async {
            switch (action) {
              case 'session.restart':
                _restart(context);
                break;
              case 'nav.backToMenu':
                _restart(context);
                break;
              default:
                await RecipeActions.handle(
                  context,
                  action,
                  onRestartSession: () => _restart(context),
                );
                break;
            }
          },
        ),
      ),
      floatingActionButton: result == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final repo = context.read<SessionHistoryRepository>();
                await repo.saveResult(result!);
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
                }
              },
              label: const Text('Save'),
              icon: const Icon(Icons.save),
            ),
    );
  }

  Map<String, String> _buildSummary() {
    if (result == null) {
      return {
        'stat1': 'No data captured.',
        'stat2': '',
        'stat3': '',
        'stat4': '',
      };
    }
    final r = result!;
    return {
      'chrome.roundLabel': 'Session Complete',
      'stat1': 'Rounds completed: ${r.roundsCompleted}/${r.presetSnapshot.rounds}',
      'stat2': 'Total active time: ${r.totalElapsedSec}s',
      'stat3': 'Total rest time: ${r.presetSnapshot.restDurationSec * r.roundsCompleted}s',
      'stat4': 'Colors used: ${Palette.resolve(r.presetSnapshot.paletteId).colors.length}',
    };
  }

  void _restart(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      MainScreen.routeName,
      (route) => false,
    );
  }
}

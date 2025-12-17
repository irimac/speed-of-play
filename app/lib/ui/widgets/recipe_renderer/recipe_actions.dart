import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../controllers/session_controller.dart';
import '../../history_screen.dart';
import '../../main_screen.dart';
import '../../session_screen.dart';
import '../../settings_screen.dart';
import '../../../data/models.dart';

class RecipeActions {
  static Future<void> handle(
    BuildContext context,
    String action, {
    SessionPreset? preset,
    ValueChanged<SessionPreset>? onPresetChanged,
    VoidCallback? onRestartSession,
    SessionController? sessionController,
  }) async {
    switch (action) {
      case 'nav.settings':
        if (preset == null || onPresetChanged == null) return;
        final updated = await Navigator.of(context).push<SessionPreset>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => SettingsScreen(
              preset: preset,
              onPresetChanged: (p) => onPresetChanged(p),
            ),
          ),
        );
        if (updated != null) {
          onPresetChanged(updated);
        }
        break;
      case 'nav.history':
        await Navigator.of(context).pushNamed(HistoryScreen.routeName);
        break;
      case 'nav.backToMenu':
        Navigator.of(context).pushNamedAndRemoveUntil(
          MainScreen.routeName,
          (r) => false,
        );
        break;
      case 'session.start':
        if (preset != null) {
          await Navigator.of(context).pushNamed(
            SessionScreen.routeName,
            arguments: preset,
          );
        }
        break;
      case 'session.restart':
        onRestartSession?.call();
        break;
      case 'session.finish':
        onRestartSession?.call();
        break;
      case 'session.resume':
        sessionController?.resume();
        break;
      case 'session.resetSession':
        sessionController?.resetSession();
        break;
      case 'session.resetRound':
        sessionController?.resetRound();
        break;
      case 'session.skipForward':
        sessionController?.skipForward();
        break;
      case 'app.exit':
        await SystemNavigator.pop();
        break;
      default:
        break;
    }
  }
}

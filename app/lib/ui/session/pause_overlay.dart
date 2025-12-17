import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../data/models.dart';
import '../styles/app_tokens.dart';
import '../styles/session_styles.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.snapshot,
    required this.onDismiss,
    required this.controller,
    required this.onFinish,
    required this.styles,
  });

  final SessionSnapshot snapshot;
  final VoidCallback onDismiss;
  final SessionController controller;
  final VoidCallback onFinish;
  final SessionStyles styles;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: styles.overlayScrimColor,
      child: Center(
        child: Padding(
          padding: styles.overlayPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: styles.overlayMaxWidth),
            child: Material(
              color: styles.overlayCardColor,
              borderRadius: BorderRadius.circular(AppTokens.cornerL),
              child: Padding(
                padding: styles.overlayPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Paused', style: styles.overlayTitleStyle),
                    const SizedBox(height: AppTokens.spacingM),
                    _OverlayButton(
                      icon: Icons.play_arrow,
                      label: 'Continue',
                      onPressed: onDismiss,
                    ),
                    _OverlayButton(
                      icon: Icons.refresh,
                      label: 'Reset Session',
                      onPressed: () {
                        controller.resetSession();
                      },
                    ),
                    _OverlayButton(
                      icon: Icons.replay,
                      label: 'Reset Round',
                      onPressed: () {
                        controller.resetRound();
                      },
                    ),
                    _OverlayButton(
                      icon: Icons.skip_next,
                      label: 'Skip Forward',
                      onPressed: () {
                        controller.skipForward();
                      },
                    ),
                    _OverlayButton(
                      icon: Icons.flag,
                      label: 'Finish Session',
                      onPressed: onFinish,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../data/models.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.snapshot,
    required this.onDismiss,
    required this.controller,
    required this.onFinish,
  });

  final SessionSnapshot snapshot;
  final VoidCallback onDismiss;
  final SessionController controller;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Paused', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
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

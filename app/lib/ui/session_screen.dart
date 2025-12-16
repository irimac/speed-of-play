import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/session_controller.dart';
import '../data/models.dart';
import 'end_screen.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.preset});

  static const routeName = '/session';

  final SessionPreset preset;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  bool _showOverlay = false;
  bool _navigatedToEnd = false;
  late final SessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<SessionController>();
    _controller.addListener(_handleControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    super.dispose();
  }

  void _handleControllerUpdate() {
    if (_navigatedToEnd) return;
    final snapshot = _controller.snapshot;
    if (snapshot.phase == SessionPhase.end && _controller.result != null) {
      _navigatedToEnd = true;
      Navigator.of(context).pushReplacementNamed(
        EndScreen.routeName,
        arguments: _controller.result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: () {
          _controller.pause();
          setState(() => _showOverlay = true);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Consumer<SessionController>(
              builder: (context, ctrl, _) {
                final snapshot = ctrl.snapshot;
                final colors = Palette.resolve(widget.preset.paletteId);
                Color background;
                if (snapshot.phase == SessionPhase.countdown) {
                  background = colors.countdownColor;
                } else if (snapshot.phase == SessionPhase.rest) {
                  background = colors.restColor;
                } else {
                  background = snapshot.currentColor ?? colors.colors.first;
                }
                final textTheme = Theme.of(context).textTheme;
                final numberStyle = textTheme.displayLarge ?? const TextStyle(fontSize: 180, fontWeight: FontWeight.bold);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: background,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SessionHeader(snapshot: snapshot),
                          Expanded(
                            child: Center(
                              child: snapshot.phase == SessionPhase.rest
                                  ? _RestIndicator(
                                      seconds: snapshot.secondsRemainingInPhase,
                                      total: widget.preset.restDurationSec,
                                    )
                                  : FittedBox(
                                      child: Text(
                                        _buildDisplayText(snapshot),
                                        style: numberStyle.copyWith(color: colors.boostedTextColor(widget.preset.outdoorBoost)),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Double-tap to pause', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_showOverlay)
              Consumer<SessionController>(
                builder: (context, ctrl, _) {
                  return _PauseOverlay(
                    snapshot: ctrl.snapshot,
                    onDismiss: _handleResume,
                    controller: ctrl,
                    onFinish: () {
                      final result = ctrl.finishEarly();
                      _navigatedToEnd = true;
                      Navigator.of(context).pushReplacementNamed(
                        EndScreen.routeName,
                        arguments: result,
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _buildDisplayText(SessionSnapshot snapshot) {
    if (snapshot.phase == SessionPhase.countdown) {
      final remaining = (widget.preset.countdownSec - snapshot.secondsIntoPhase).clamp(0, widget.preset.countdownSec);
      return '-$remaining';
    }
    return snapshot.currentNumber?.toString() ?? '--';
  }

  void _handleResume() {
    _controller.resume();
    setState(() => _showOverlay = false);
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.snapshot});

  final SessionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final timerText = snapshot.phase == SessionPhase.rest
        ? 'Rest ${snapshot.secondsRemainingInPhase}s'
        : '${snapshot.secondsRemainingInPhase}s left';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Round ${snapshot.roundIndex + 1}/${snapshot.roundsTotal}', style: const TextStyle(fontSize: 24)),
        Text(timerText, style: const TextStyle(fontSize: 20)),
      ],
    );
  }
}

class _RestIndicator extends StatelessWidget {
  const _RestIndicator({required this.seconds, required this.total});

  final int seconds;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CircularProgressIndicator(
            value: total == 0 ? 0 : seconds / total,
            strokeWidth: 8,
            backgroundColor: Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 16),
        Text('$seconds s', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
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
      color: Colors.black.withOpacity(0.75),
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
                      onPressed: snapshot.phase == SessionPhase.active
                          ? () {
                              controller.skipForward();
                            }
                          : null,
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

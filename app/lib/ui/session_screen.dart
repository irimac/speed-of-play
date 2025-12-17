import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/session_controller.dart';
import '../data/models.dart';
import 'end_screen.dart';
import 'session/active_round_view.dart';
import 'session/countdown_view.dart';
import 'session/pause_overlay.dart';
import 'session/rest_view.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  static const routeName = '/session';

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
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
          final snapshot = _controller.snapshot;
          if (!snapshot.isPaused && snapshot.phase != SessionPhase.end) {
            _controller.pause();
          }
        },
        child: Consumer<SessionController>(
          builder: (context, ctrl, _) {
            final snapshot = ctrl.snapshot;
            if (snapshot.phase == SessionPhase.end) {
              return const SizedBox.shrink();
            }
            final colors = Palette.resolve(ctrl.preset.paletteId);
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
            final restTotal = snapshot.secondsIntoPhase + snapshot.secondsRemainingInPhase;
            return Stack(
              fit: StackFit.expand,
              children: [
                AnimatedContainer(
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
                              child: _buildPhaseView(
                                snapshot: snapshot,
                                colors: colors,
                                numberStyle: numberStyle,
                                restTotal: restTotal,
                                outdoorBoost: ctrl.preset.outdoorBoost,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Double-tap to pause', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
                if (snapshot.isPaused && snapshot.phase != SessionPhase.end)
                  PauseOverlay(
                    snapshot: snapshot,
                    onDismiss: ctrl.resume,
                    controller: ctrl,
                    onFinish: () {
                      final result = ctrl.finishEarly();
                      _navigatedToEnd = true;
                      Navigator.of(context).pushReplacementNamed(
                        EndScreen.routeName,
                        arguments: result,
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhaseView({
    required SessionSnapshot snapshot,
    required Palette colors,
    required TextStyle numberStyle,
    required int restTotal,
    required bool outdoorBoost,
  }) {
    if (snapshot.phase == SessionPhase.countdown) {
      return CountdownView(
        remainingSeconds: snapshot.secondsRemainingInPhase,
        textStyle: numberStyle.copyWith(color: colors.boostedTextColor(outdoorBoost)),
      );
    }
    if (snapshot.phase == SessionPhase.rest) {
      return RestView(
        secondsRemaining: snapshot.secondsRemainingInPhase,
        totalSeconds: restTotal,
      );
    }
    return ActiveRoundView(
      displayText: snapshot.currentNumber?.toString() ?? '--',
      textStyle: numberStyle.copyWith(color: colors.boostedTextColor(outdoorBoost)),
    );
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

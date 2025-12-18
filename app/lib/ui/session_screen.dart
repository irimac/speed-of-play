import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/session_controller.dart';
import '../data/models.dart';
import 'end_screen.dart';
import 'session/active_round_view.dart';
import 'session/countdown_view.dart';
import 'session/pause_overlay.dart';
import 'session/rest_view.dart';
import 'styles/session_styles.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  static const routeName = '/session';

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> with WidgetsBindingObserver {
  bool _navigatedToEnd = false;
  late final SessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<SessionController>();
    _controller.addListener(_handleControllerUpdate);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      _controller.pause();
    }
    super.didChangeAppLifecycleState(state);
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
            final styles = SessionStyles.defaults(
              Theme.of(context),
              largeSessionText: ctrl.preset.largeSessionText,
            );
            final colors = Palette.resolveWithContrast(
              ctrl.preset.paletteId,
              highContrast: ctrl.preset.highContrastPalette,
            );
            Color background;
            if (snapshot.phase == SessionPhase.countdown) {
              background = colors.countdownColor;
            } else if (snapshot.phase == SessionPhase.rest) {
              background = colors.restColor;
            } else {
              background = snapshot.currentColor ?? colors.colors.first;
            }
            final restTotal = snapshot.secondsIntoPhase + snapshot.secondsRemainingInPhase;
            return Stack(
              fit: StackFit.expand,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: background,
                  child: SafeArea(
                    child: Padding(
                      padding: styles.screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SessionHeader(snapshot: snapshot, styles: styles),
                          Expanded(
                            child: Center(
                              child: _buildPhaseView(
                                snapshot: snapshot,
                                colors: colors,
                                numberStyle: styles.numberTextStyle,
                                restTotal: restTotal,
                                outdoorBoost: ctrl.preset.outdoorBoost,
                                styles: styles,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('Double-tap to pause', textAlign: TextAlign.center, style: styles.hintTextStyle),
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
                    styles: styles,
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
    required SessionStyles styles,
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
        indicatorSize: styles.restIndicatorSize,
        strokeWidth: styles.restStrokeWidth,
        backgroundColor: styles.restIndicatorBackground,
      );
    }
    return ActiveRoundView(
      displayText: snapshot.currentNumber?.toString() ?? '--',
      textStyle: numberStyle.copyWith(color: colors.boostedTextColor(outdoorBoost)),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.snapshot, required this.styles});

  final SessionSnapshot snapshot;
  final SessionStyles styles;

  @override
  Widget build(BuildContext context) {
    final timerText = snapshot.phase == SessionPhase.rest
        ? 'Rest ${snapshot.secondsRemainingInPhase}s'
        : '${snapshot.secondsRemainingInPhase}s left';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Round ${snapshot.roundIndex + 1}/${snapshot.roundsTotal}', style: styles.headerRoundTextStyle),
        Text(timerText, style: styles.headerTimerTextStyle),
      ],
    );
  }
}

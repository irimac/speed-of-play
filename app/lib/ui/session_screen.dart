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

class _SessionScreenState extends State<SessionScreen>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
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
            final restTotal =
                snapshot.secondsIntoPhase + snapshot.secondsRemainingInPhase;
            final maxAbsNumber =
                ctrl.preset.numberMin.abs() > ctrl.preset.numberMax.abs()
                    ? ctrl.preset.numberMin.abs()
                    : ctrl.preset.numberMax.abs();
            final numberDigits = maxAbsNumber.toString().length;
            final needsNumberSign = ctrl.preset.numberMin < 0;
            final activeSizingText =
                '${needsNumberSign ? '-' : ''}${_repeatChar('8', numberDigits)}';
            final countdownDigits =
                (ctrl.preset.countdownSec <= 0 ? 0 : ctrl.preset.countdownSec)
                    .toString()
                    .length;
            final countdownSizingText = '-${_repeatChar('8', countdownDigits)}';
            final headerTextColor = styles.textOnStimulus(background);
            final scrimColor = styles.scrimColorForBackground(background);
            return Stack(
              fit: StackFit.expand,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: background,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SessionHeader(
                          snapshot: snapshot,
                          styles: styles,
                          textColor: headerTextColor,
                          scrimColor: scrimColor,
                        ),
                        Expanded(
                          child: Padding(
                            padding: styles.screenPadding,
                            child: Center(
                              child: _buildPhaseView(
                                snapshot: snapshot,
                                numberStyle: styles.numberTextStyle,
                                backgroundColor: background,
                                restTotal: restTotal,
                                outdoorBoost: ctrl.preset.outdoorBoost,
                                styles: styles,
                                activeSizingText: activeSizingText,
                                countdownSizingText: countdownSizingText,
                              ),
                            ),
                          ),
                        ),
                        _SessionFooter(
                          styles: styles,
                          textColor: headerTextColor,
                          scrimColor: scrimColor,
                        ),
                      ],
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
    required TextStyle numberStyle,
    required Color backgroundColor,
    required int restTotal,
    required bool outdoorBoost,
    required SessionStyles styles,
    required String activeSizingText,
    required String countdownSizingText,
  }) {
    final contrastColor = styles.textOnStimulus(backgroundColor);
    final shadowScale = outdoorBoost ? styles.numberShadowBoost : 1.0;
    final numberShadows =
        styles.numberShadowsForText(contrastColor, intensity: shadowScale);
    final primaryNumberStyle = numberStyle.copyWith(
      color: contrastColor,
      shadows: numberShadows,
    );

    if (snapshot.phase == SessionPhase.countdown) {
      return CountdownView(
        remainingSeconds: snapshot.secondsRemainingInPhase,
        textStyle: primaryNumberStyle,
        sizingText: countdownSizingText,
      );
    }
    if (snapshot.phase == SessionPhase.rest) {
      return RestView(
        secondsRemaining: snapshot.secondsRemainingInPhase,
        totalSeconds: restTotal,
        indicatorSize: styles.restIndicatorSize,
        strokeWidth: styles.restStrokeWidth,
        innerPadding: styles.restInnerPadding,
        backgroundColor: styles.restIndicatorBackground,
        textStyle: styles.restSecondsTextStyle.copyWith(
          color: contrastColor,
          shadows: numberShadows,
        ),
      );
    }
    return ActiveRoundView(
      displayText: snapshot.currentNumber?.toString() ?? '--',
      textStyle: primaryNumberStyle,
      sizingText: activeSizingText,
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.snapshot,
    required this.styles,
    required this.textColor,
    required this.scrimColor,
  });

  final SessionSnapshot snapshot;
  final SessionStyles styles;
  final Color textColor;
  final Color scrimColor;

  @override
  Widget build(BuildContext context) {
    final remainingText = _formatSeconds(snapshot.secondsRemainingInPhase);
    final timerText = snapshot.phase == SessionPhase.rest
        ? 'Rest $remainingText'
        : '$remainingText left';
    return Container(
      height: styles.headerHeight,
      padding: styles.headerPadding,
      color: scrimColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Round ${snapshot.roundIndex + 1}/${snapshot.roundsTotal}',
            style: styles.headerRoundTextStyle.copyWith(color: textColor),
          ),
          Text(
            timerText,
            style: styles.headerTimerTextStyle.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _SessionFooter extends StatelessWidget {
  const _SessionFooter({
    required this.styles,
    required this.textColor,
    required this.scrimColor,
  });

  final SessionStyles styles;
  final Color textColor;
  final Color scrimColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: styles.footerHeight,
      padding: styles.footerPadding,
      color: scrimColor,
      alignment: Alignment.center,
      child: Text(
        'Double-tap to pause',
        textAlign: TextAlign.center,
        style: styles.hintTextStyle.copyWith(color: textColor),
      ),
    );
  }
}

String _formatSeconds(int seconds) {
  final clamped = seconds < 0 ? 0 : seconds;
  final minutes = clamped ~/ 60;
  final remaining = clamped % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remaining.toString().padLeft(2, '0')}';
}

String _repeatChar(String char, int count) {
  if (count <= 0) return char;
  return List.filled(count, char).join();
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/session_controller.dart';
import '../data/models.dart';
import 'end_screen.dart';
import 'widgets/recipe_renderer/recipe_renderer.dart';
import 'widgets/recipe_renderer/recipe_actions.dart';

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
                final screen = snapshot.phase == SessionPhase.countdown
                    ? 'countdown'
                    : snapshot.phase == SessionPhase.rest
                        ? 'rest'
                        : 'active_session';
                final colors = Palette.resolve(widget.preset.paletteId);
                final bgColor = snapshot.phase == SessionPhase.countdown
                    ? colors.countdownColor
                    : snapshot.phase == SessionPhase.rest
                        ? colors.restColor
                        : snapshot.currentColor ?? colors.colors.first;
                final roundText = 'Round ${snapshot.roundIndex + 1} / ${snapshot.roundsTotal}';
                final currentPhaseTotal = snapshot.phase == SessionPhase.active
                    ? widget.preset.roundDurationSec
                    : snapshot.phase == SessionPhase.rest
                        ? widget.preset.restDurationSec
                        : widget.preset.countdownSec;
                final timeText =
                    'Time: ${_formatTime(snapshot.secondsIntoPhase)} / ${_formatTime(currentPhaseTotal)}';
                final sessionElapsed = _computeSessionElapsed(snapshot);
                final bottomText = 'Session Time: ${_formatTime(sessionElapsed)}';
                final overrides = <String, String>{
                  'chrome.roundLabel': roundText,
                  'chrome.timeLabel': timeText,
                  'chrome.bottomTimer': bottomText,
                  'body.bigNumber': _buildDisplayText(snapshot),
                  'body.restNumber': snapshot.secondsRemainingInPhase.toString(),
                };
                final colorOverrides = <String, Color>{
                  'bg': bgColor,
                };
                final progressOverrides = <String, double>{
                  'body.restRing': widget.preset.restDurationSec == 0
                      ? 0
                      : snapshot.secondsRemainingInPhase / widget.preset.restDurationSec,
                };
                return RecipeRenderer(
                  screen: screen,
                  textOverrides: overrides,
                  colorOverrides: colorOverrides,
                  progressOverrides: progressOverrides,
                  onAction: (action) => RecipeActions.handle(
                    context,
                    action,
                    sessionController: ctrl,
                  ),
                );
              },
            ),
            if (_showOverlay)
              Consumer<SessionController>(
                builder: (context, ctrl, _) {
                  return RecipeRenderer(
                    screen: 'pause_overlay',
                    onAction: (action) async {
                      if (action == 'session.finish') {
                        final result = ctrl.finishEarly();
                        _navigatedToEnd = true;
                        if (!mounted) return;
                        await Navigator.of(context).pushReplacementNamed(
                          EndScreen.routeName,
                          arguments: result,
                        );
                        return;
                      }
                      await RecipeActions.handle(
                        context,
                        action,
                        sessionController: ctrl,
                      );
                      if (!mounted) return;
                      setState(() => _showOverlay = false);
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

  int _computeSessionElapsed(SessionSnapshot snapshot) {
    final countdown = widget.preset.countdownSec;
    final round = widget.preset.roundDurationSec;
    final rest = widget.preset.restDurationSec;
    switch (snapshot.phase) {
      case SessionPhase.countdown:
        return snapshot.secondsIntoPhase;
      case SessionPhase.active:
        // Completed countdown + previous rounds (with rests) + current phase progress.
        return countdown + snapshot.roundIndex * (round + rest) + snapshot.secondsIntoPhase;
      case SessionPhase.rest:
        // Just finished a round; include that round plus prior rests, and current rest time.
        return countdown + (snapshot.roundIndex + 1) * round + snapshot.roundIndex * rest + snapshot.secondsIntoPhase;
      case SessionPhase.end:
        return countdown + widget.preset.rounds * (round + rest);
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

/// Emits aligned “second” ticks derived from a monotonic [Stopwatch].
class SessionScheduler {
  SessionScheduler({
    required void Function(int secondsSinceStart) onAlignedSecond,
  }) : _onAlignedSecond = onAlignedSecond {
    _ticker = Ticker(_handleTick);
  }

  final void Function(int) _onAlignedSecond;
  late final Stopwatch _stopwatch = Stopwatch();
  late final Ticker _ticker;
  int _lastEmittedSecond = -1;
  int? _resumeHoldUntilSecond;
  bool _disposed = false;

  void start() {
    _stopwatch.reset();
    _stopwatch.start();
    _lastEmittedSecond = -1;
    _resumeHoldUntilSecond = null;
    _ticker.start();
  }

  void _handleTick(Duration _) {
    if (_disposed) return;
    final elapsedMs = _stopwatch.elapsedMilliseconds;
    final second = elapsedMs ~/ 1000;

    if (_resumeHoldUntilSecond != null) {
      if (second < _resumeHoldUntilSecond!) {
        return;
      }
      _resumeHoldUntilSecond = null;
      _lastEmittedSecond = second - 1;
    }

    if (second == _lastEmittedSecond) return;
    _lastEmittedSecond = second;
    _onAlignedSecond(second);
  }

  void pause() {
    if (!_stopwatch.isRunning) return;
    _stopwatch.stop();
    _ticker.stop();
  }

  void resume() {
    if (_stopwatch.isRunning) return;
    final seconds = _stopwatch.elapsedMilliseconds ~/ 1000;
    _resumeHoldUntilSecond = seconds + 1;
    _stopwatch.start();
    _ticker.start();
  }

  void dispose() {
    _disposed = true;
    _ticker.dispose();
    _stopwatch.stop();
  }

  @visibleForTesting
  void debugEmitSecond(int secondSinceStart) {
    _onAlignedSecond(secondSinceStart);
  }
}

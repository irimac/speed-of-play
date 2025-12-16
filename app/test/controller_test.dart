import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/controllers/session_controller.dart';
import 'package:speed_of_play/data/models.dart';
import 'package:speed_of_play/services/audio_cue_player.dart';
import 'package:speed_of_play/services/session_scheduler.dart';

class _NoopAudioPlayer extends AudioCuePlayer {
  @override
  Future<void> ensureLoaded() async {}

  @override
  Future<void> playRoundStart() async {}

  @override
  Future<void> playTick() async {}
}

class _ManualScheduler extends SessionScheduler {
  _ManualScheduler(void Function(int secondsSinceStart) onAlignedSecond)
      : super(onAlignedSecond: onAlignedSecond);

  int _seconds = 0;
  bool _running = false;

  @override
  void start() {
    _seconds = 0;
    _running = true;
  }

  @override
  void pause() {
    _running = false;
  }

  @override
  void resume() {
    _running = true;
  }

  @override
  void dispose() {
    _running = false;
  }

  void tick([int step = 1]) {
    if (!_running) return;
    for (var i = 0; i < step; i++) {
      _seconds += 1;
      onAlignedSecond(_seconds);
    }
  }
}

class _TestController extends SessionController {
  _TestController({
    required SessionPreset preset,
    required _ManualScheduler scheduler,
  }) : super(
          preset: preset,
          audioPlayer: _NoopAudioPlayer(),
        ) {
    // Override the scheduler used internally.
    // ignore: invalid_use_of_visible_for_testing_member
    // ignore: invalid_use_of_protected_member
    // ignore: unnecessary_this
    this._scheduler = scheduler;
  }
}

void main() {
  group('SessionController', () {
    test('transitions from countdown to active and emits stimuli', () {
      final scheduler = _ManualScheduler((_) {});
      final preset = SessionPreset.defaults().copyWith(
        countdownSec: 2,
        roundDurationSec: 4,
        changeIntervalSec: 1,
        restDurationSec: 0,
        rngSeed: 1, // deterministic
      );
      final controller = _TestController(preset: preset, scheduler: scheduler);
      controller.start();

      expect(controller.snapshot.phase, SessionPhase.countdown);
      scheduler.tick(); // 1s
      scheduler.tick(); // 2s -> should enter active and emit
      expect(controller.snapshot.phase, SessionPhase.active);
      expect(controller.snapshot.currentNumber, isNotNull);
      final firstNumber = controller.snapshot.currentNumber;

      scheduler.tick(); // 1s into active -> change interval 1s, new number
      expect(controller.snapshot.currentNumber, isNotNull);
      expect(controller.snapshot.currentNumber, isNot(firstNumber));
    });

    test('ends after configured rounds without rest', () {
      final scheduler = _ManualScheduler((_) {});
      final preset = SessionPreset.defaults().copyWith(
        countdownSec: 0,
        roundDurationSec: 2,
        changeIntervalSec: 1,
        restDurationSec: 0,
        rounds: 1,
        rngSeed: 2,
      );
      final controller = _TestController(preset: preset, scheduler: scheduler);
      controller.start();
      expect(controller.snapshot.phase, SessionPhase.active);

      scheduler.tick(2); // complete round
      expect(controller.snapshot.phase, SessionPhase.end);
      expect(controller.result, isNotNull);
      expect(controller.result!.roundsCompleted, 1);
    });
  });
}

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
      debugEmitSecond(_seconds);
    }
  }
}

class _CountingAudio extends AudioCuePlayer {
  int roundStarts = 0;
  int ticks = 0;

  @override
  Future<void> ensureLoaded() async {}

  @override
  Future<void> playRoundStart() async {
    roundStarts++;
  }

  @override
  Future<void> playTick() async {
    ticks++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionController', () {
    test('transitions from countdown to active and emits stimuli', () {
      _ManualScheduler scheduler = _ManualScheduler((_) {});
      final preset = SessionPreset.defaults().copyWith(
        countdownSec: 2,
        roundDurationSec: 4,
        changeIntervalSec: 1,
        restDurationSec: 0,
        rngSeed: 1, // deterministic
      );
      final controller = SessionController(
        preset: preset,
        audioPlayer: _NoopAudioPlayer(),
        schedulerBuilder: (cb) {
          scheduler = _ManualScheduler(cb);
          return scheduler;
        },
        wakelockEnable: () async {},
        wakelockDisable: () async {},
      );
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
      _ManualScheduler scheduler = _ManualScheduler((_) {});
      final preset = SessionPreset.defaults().copyWith(
        countdownSec: 0,
        roundDurationSec: 2,
        changeIntervalSec: 1,
        restDurationSec: 0,
        rounds: 1,
        rngSeed: 2,
      );
      final controller = SessionController(
        preset: preset,
        audioPlayer: _NoopAudioPlayer(),
        schedulerBuilder: (cb) {
          scheduler = _ManualScheduler(cb);
          return scheduler;
        },
        wakelockEnable: () async {},
        wakelockDisable: () async {},
      );
      controller.start();
      expect(controller.snapshot.phase, SessionPhase.active);

      scheduler.tick(3); // complete round (>= roundDurationSec)
      expect(controller.snapshot.phase, SessionPhase.end);
      expect(controller.result, isNotNull);
      expect(controller.result!.roundsCompleted, 1);
    });

    test('skipForward works across countdown/active/rest and stays paused', () {
      _ManualScheduler scheduler = _ManualScheduler((_) {});
      final preset = SessionPreset.defaults().copyWith(
        countdownSec: 2,
        roundDurationSec: 4,
        changeIntervalSec: 1,
        restDurationSec: 2,
        rounds: 2,
        rngSeed: 3,
      );
      final controller = SessionController(
        preset: preset,
        audioPlayer: _NoopAudioPlayer(),
        schedulerBuilder: (cb) {
          scheduler = _ManualScheduler(cb);
          return scheduler;
        },
        wakelockEnable: () async {},
        wakelockDisable: () async {},
      );

      controller.start();
      controller.pause();
      controller.skipForward(); // countdown -> active
      expect(controller.snapshot.phase, SessionPhase.active);
      expect(controller.snapshot.isPaused, isTrue);

      controller.resume();
      scheduler.tick(2); // run part of the round
      controller.pause();
      controller.skipForward(); // active -> rest
      expect(controller.snapshot.phase, SessionPhase.rest);
      expect(controller.snapshot.isPaused, isTrue);

      controller.skipForward(); // rest -> next active
      expect(controller.snapshot.phase, SessionPhase.active);
      expect(controller.snapshot.roundIndex, 1);
      expect(controller.snapshot.isPaused, isTrue);
    });

    test('skipping from rest keeps elapsed rest time in totals', () {
      _ManualScheduler scheduler = _ManualScheduler((_) {});
      final preset = SessionPreset.defaults().copyWith(
        countdownSec: 0,
        roundDurationSec: 2,
        changeIntervalSec: 1,
        restDurationSec: 5,
        rounds: 2,
        rngSeed: 7,
      );
      final controller = SessionController(
        preset: preset,
        audioPlayer: _NoopAudioPlayer(),
        schedulerBuilder: (cb) {
          scheduler = _ManualScheduler(cb);
          return scheduler;
        },
        wakelockEnable: () async {},
        wakelockDisable: () async {},
      );

      controller.start();
      scheduler.tick(2); // complete first active
      scheduler.tick(3); // 3s into rest
      expect(controller.snapshot.phase, SessionPhase.rest);

      controller.pause();
      controller.skipForward(); // rest -> next active, keep rest time

      expect(controller.snapshot.phase, SessionPhase.active);
      expect(controller.snapshot.isPaused, isTrue);
      final result = controller.finishEarly();
      expect(result.roundsCompleted, 1);
      expect(result.totalElapsedSec, 5); // 2 active + 3 rest elapsed
    });

    test('result uses actual elapsed time and per-round durations', () {
      _ManualScheduler scheduler = _ManualScheduler((_) {});
      final preset = SessionPreset.defaults().copyWith(
        countdownSec: 1,
        roundDurationSec: 3,
        changeIntervalSec: 1,
        restDurationSec: 1,
        rounds: 2,
        rngSeed: 4,
      );
      final controller = SessionController(
        preset: preset,
        audioPlayer: _NoopAudioPlayer(),
        schedulerBuilder: (cb) {
          scheduler = _ManualScheduler(cb);
          return scheduler;
        },
        wakelockEnable: () async {},
        wakelockDisable: () async {},
      );

      controller.start();
      scheduler.tick(); // countdown completes -> active starts
      scheduler.tick(3); // first round complete (3s)
      scheduler.tick(); // rest complete (1s)
      scheduler.tick(2); // two seconds into second round

      final result = controller.finishEarly();
      expect(result.roundsCompleted, 1); // only first active completed
      expect(result.perRoundDurationsSec, [3]);
      expect(result.totalElapsedSec, 7); // 1 countdown + 3 + 1 rest + 2 active
    });

    test('skipForward while paused does not play round-start audio', () {
      _ManualScheduler scheduler = _ManualScheduler((_) {});
      final audio = _CountingAudio();
      final preset = SessionPreset.defaults().copyWith(
        countdownSec: 2,
        roundDurationSec: 4,
        restDurationSec: 2,
        changeIntervalSec: 1,
        rounds: 2,
        rngSeed: 5,
      );
      final controller = SessionController(
        preset: preset,
        audioPlayer: audio,
        schedulerBuilder: (cb) {
          scheduler = _ManualScheduler(cb);
          return scheduler;
        },
        wakelockEnable: () async {},
        wakelockDisable: () async {},
      );

      controller.start();
      controller.pause();
      controller.skipForward(); // countdown -> active while paused

      expect(controller.snapshot.phase, SessionPhase.active);
      expect(controller.snapshot.isPaused, isTrue);
      expect(audio.roundStarts, 0);
    });
  });
}

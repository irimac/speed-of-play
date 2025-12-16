import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/models.dart';
import '../services/audio_cue_player.dart';
import '../services/session_scheduler.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required this.preset,
    AudioCuePlayer? audioPlayer,
  })  : _audio = audioPlayer ?? AudioCuePlayer(),
        _rng = Random(preset.rngSeed) {
    _snapshot = SessionSnapshot(
      phase: preset.countdownSec > 0 ? SessionPhase.countdown : SessionPhase.active,
      secondsIntoPhase: 0,
      secondsRemainingInPhase: preset.countdownSec,
      roundIndex: 0,
      roundsTotal: preset.rounds,
      currentNumber: null,
      currentColor: null,
      isPaused: true,
      isLastRound: preset.rounds == 1,
    );
    _scheduler = SessionScheduler(onAlignedSecond: _handleAlignedSecond);
  }

  final SessionPreset preset;
  late final SessionScheduler _scheduler;
  final Random _rng;
  final AudioCuePlayer _audio;
  late SessionSnapshot _snapshot;
  int _roundIndex = 0;
  int _secondsIntoPhase = 0;
  SessionPhase _phase = SessionPhase.countdown;
  final List<Stimulus> _stimuli = [];
  bool _isRunning = false;
  bool _paused = true;
  int? _phaseDuration;
  Stimulus? _lastStimulus;
  SessionResult? _finalResult;

  SessionSnapshot get snapshot => _snapshot;
  SessionResult? get result => _finalResult;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _paused = false;
    _phase = preset.countdownSec > 0 ? SessionPhase.countdown : SessionPhase.active;
    _secondsIntoPhase = 0;
    _roundIndex = 0;
    _phaseDuration = _phase == SessionPhase.countdown ? preset.countdownSec : preset.roundDurationSec;
    _stimuli.clear();
    _finalResult = null;
    unawaited(_audio.ensureLoaded());
    if (_phase == SessionPhase.active) {
      _emitStimulus(force: true);
    }
    _scheduler.start();
    WakelockPlus.enable();
    _updateSnapshot();
  }

  void pause() {
    if (_paused || !_isRunning) return;
    _paused = true;
    _scheduler.pause();
    _updateSnapshot();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    _scheduler.resume();
    _updateSnapshot();
  }

  void resetSession() {
    _scheduler.pause();
    _roundIndex = 0;
    _secondsIntoPhase = 0;
    _phase = preset.countdownSec > 0 ? SessionPhase.countdown : SessionPhase.active;
    _phaseDuration = _phase == SessionPhase.countdown ? preset.countdownSec : preset.roundDurationSec;
    _stimuli.clear();
    _lastStimulus = null;
    _paused = true;
    _isRunning = false;
    _finalResult = null;
    WakelockPlus.disable();
    _snapshot = SessionSnapshot(
      phase: _phase,
      secondsIntoPhase: 0,
      secondsRemainingInPhase: _phaseDuration ?? 0,
      roundIndex: 0,
      roundsTotal: preset.rounds,
      currentNumber: null,
      currentColor: null,
      isPaused: true,
      isLastRound: preset.rounds == 1,
    );
    notifyListeners();
  }

  void resetRound() {
    if (_phase == SessionPhase.countdown) {
      resetSession();
      return;
    }
    _secondsIntoPhase = 0;
    _phase = SessionPhase.active;
    _phaseDuration = preset.roundDurationSec;
    _paused = true;
    _scheduler.pause();
    _finalResult = null;
    _emitStimulus(force: true);
    _updateSnapshot();
  }

  void skipForward() {
    if (_phase != SessionPhase.active) return;
    final isLastRound = _roundIndex >= preset.rounds - 1;
    if (isLastRound) {
      _phase = SessionPhase.end;
      _paused = true;
      _scheduler.pause();
      _finalResult = _buildResult();
      _isRunning = false;
      WakelockPlus.disable();
    } else {
      _phase = SessionPhase.rest;
      _secondsIntoPhase = 0;
      _phaseDuration = preset.restDurationSec;
      _paused = true;
      _scheduler.pause();
    }
    _updateSnapshot();
  }

  SessionResult finishEarly() {
    _phase = SessionPhase.end;
    _scheduler.pause();
    _paused = true;
    _isRunning = false;
    WakelockPlus.disable();
    _finalResult = _buildResult();
    notifyListeners();
    return _finalResult!;
  }

  @override
  void dispose() {
    _scheduler.dispose();
    unawaited(_audio.dispose());
    super.dispose();
  }

  void _handleAlignedSecond(int secondSinceStart) {
    if (_paused) return;
    unawaited(_audio.playTick());
    _secondsIntoPhase += 1;
    if (_phase == SessionPhase.countdown) {
      if (_secondsIntoPhase >= (preset.countdownSec)) {
        _enterActiveRound(emitStimulus: true);
      }
    } else if (_phase == SessionPhase.active) {
      if (_secondsIntoPhase % preset.changeIntervalSec == 0) {
        _emitStimulus();
      }
      if (_secondsIntoPhase >= preset.roundDurationSec) {
        _advanceFromActive();
      }
    } else if (_phase == SessionPhase.rest) {
      if (_secondsIntoPhase >= preset.restDurationSec) {
        _advanceFromRest();
      }
    }
    _updateSnapshot();
  }

  void _advanceFromActive() {
    final isLastRound = _roundIndex >= preset.rounds - 1;
    if (isLastRound) {
      _phase = SessionPhase.end;
      _scheduler.pause();
      _paused = true;
      _isRunning = false;
      WakelockPlus.disable();
      _finalResult = _buildResult();
    } else {
      if (preset.restDurationSec == 0) {
        _roundIndex += 1;
        _enterActiveRound(emitStimulus: true);
        return;
      }
      _phase = SessionPhase.rest;
      _phaseDuration = preset.restDurationSec;
      _secondsIntoPhase = 0;
    }
  }

  void _advanceFromRest() {
    _roundIndex += 1;
    _enterActiveRound(emitStimulus: true);
  }

  void _enterActiveRound({required bool emitStimulus}) {
    _phase = SessionPhase.active;
    _phaseDuration = preset.roundDurationSec;
    _secondsIntoPhase = 0;
    if (emitStimulus) {
      _emitStimulus(force: true);
    }
    unawaited(_audio.playRoundStart());
  }

  void _emitStimulus({bool force = false}) {
    int number;
    do {
      number = randomInRange(_rng, preset.numberMin, preset.numberMax);
    } while (!force && _lastStimulus != null && _lastStimulus!.number == number);
    final palette = Palette.resolve(preset.paletteId);
    Color color;
    do {
      color = palette.colors[_rng.nextInt(palette.colors.length)];
    } while (!force && _lastStimulus != null && _lastStimulus!.colorId == color.value.toRadixString(16));
    final stimulus = Stimulus(
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      colorId: color.value.toRadixString(16),
      number: number,
    );
    _lastStimulus = stimulus;
    _stimuli.add(stimulus);
    _snapshot = _snapshot.copyWith(
      currentNumber: number,
      currentColor: color,
    );
  }

  SessionResult _buildResult() {
    var completedRounds = _roundIndex;
    if (_phase == SessionPhase.end) {
      completedRounds = _roundIndex + 1;
    }
    final roundsInt = completedRounds.clamp(0, preset.rounds).toInt();
    final perRound = List<int>.filled(roundsInt, preset.roundDurationSec);
    return SessionResult(
      completedAt: DateTime.now(),
      presetSnapshot: preset,
      roundsCompleted: roundsInt,
      perRoundDurationsSec: perRound,
      totalElapsedSec: roundsInt * preset.roundDurationSec,
      stimuli: List.unmodifiable(_stimuli),
    );
  }

  void _updateSnapshot() {
    final secondsRemaining =
        (_phaseDuration ?? 0) - _secondsIntoPhase >= 0 ? (_phaseDuration ?? 0) - _secondsIntoPhase : 0;
    final palette = Palette.resolve(preset.paletteId);
    _snapshot = _snapshot.copyWith(
      phase: _phase,
      secondsIntoPhase: _secondsIntoPhase,
      secondsRemainingInPhase: secondsRemaining,
      roundIndex: _roundIndex,
      roundsTotal: preset.rounds,
      currentNumber: _snapshot.currentNumber,
      currentColor: _snapshot.currentColor ?? palette.countdownColor,
      isPaused: _paused,
      isLastRound: _roundIndex >= preset.rounds - 1,
    );
    notifyListeners();
  }
}

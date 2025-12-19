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
    SessionScheduler Function(void Function(int secondSinceStart))?
        schedulerBuilder,
    Future<void> Function()? wakelockEnable,
    Future<void> Function()? wakelockDisable,
  })  : _audio = audioPlayer ?? AudioCuePlayer(),
        _rng = Random(preset.rngSeed) {
    _scheduler = (schedulerBuilder ??
        (cb) => SessionScheduler(onAlignedSecond: cb))(_handleAlignedSecond);
    _wakelockEnable = wakelockEnable ?? WakelockPlus.enable;
    _wakelockDisable = wakelockDisable ?? WakelockPlus.disable;
    _resetState(startPaused: true);
  }

  final SessionPreset preset;
  late final SessionScheduler _scheduler;
  final Random _rng;
  final AudioCuePlayer _audio;
  late final Future<void> Function() _wakelockEnable;
  late final Future<void> Function() _wakelockDisable;
  late SessionSnapshot _snapshot;
  int _roundIndex = 0;
  int _secondsIntoPhase = 0;
  int _elapsedSeconds = 0;
  SessionPhase _phase = SessionPhase.countdown;
  final List<int> _roundDurations = [];
  final List<Stimulus> _stimuli = [];
  bool _isRunning = false;
  bool _paused = true;
  int? _phaseDuration;
  Stimulus? _lastStimulus;
  SessionResult? _finalResult;
  int _lastTickAudioSecond = -1;
  int _lastRoundStartRound = -1;

  SessionSnapshot get snapshot => _snapshot;
  SessionResult? get result => _finalResult;

  void start() {
    if (_isRunning) return;
    _resetState(startPaused: false);
    if (preset.audioEnabled) {
      unawaited(_audio.ensureLoaded());
    }
    _scheduler.start();
    _invokeWakelock(_wakelockEnable);
    _updateSnapshot();
  }

  void _resetState({required bool startPaused}) {
    _isRunning = !startPaused;
    _paused = startPaused;
    _phase =
        preset.countdownSec > 0 ? SessionPhase.countdown : SessionPhase.active;
    _secondsIntoPhase = 0;
    _elapsedSeconds = 0;
    _roundIndex = 0;
    _phaseDuration = _phase == SessionPhase.countdown
        ? preset.countdownSec
        : preset.roundDurationSec;
    _stimuli.clear();
    _roundDurations.clear();
    _lastStimulus = null;
    _finalResult = null;
    _lastTickAudioSecond = -1;
    _lastRoundStartRound = -1;
    _snapshot = SessionSnapshot(
      phase: _phase,
      secondsIntoPhase: 0,
      secondsRemainingInPhase: _phaseDuration ?? 0,
      elapsedSeconds: 0,
      roundIndex: 0,
      roundsTotal: preset.rounds,
      currentNumber: null,
      currentColor: null,
      isPaused: _paused,
      isLastRound: preset.rounds == 1,
    );
    if (_phase == SessionPhase.active) {
      _emitStimulus(force: true);
    }
    if (startPaused) {
      _scheduler.pause();
    }
  }

  void pause() {
    if (_paused || !_isRunning) return;
    _paused = true;
    _scheduler.pause();
    _updateSnapshot();
  }

  void resume() {
    if (!_paused || _phase == SessionPhase.end) return;
    _paused = false;
    if (_isRunning) {
      _scheduler.resume();
    } else {
      _isRunning = true;
      _scheduler.start();
      _invokeWakelock(_wakelockEnable);
    }
    _updateSnapshot();
  }

  void resetSession() {
    _scheduler.pause();
    _resetState(startPaused: true);
    _updateSnapshot();
  }

  void resetRound() {
    if (_phase == SessionPhase.countdown) {
      resetSession();
      return;
    }
    if (_secondsIntoPhase > 0) {
      _elapsedSeconds = (_elapsedSeconds - _secondsIntoPhase)
          .clamp(0, _elapsedSeconds)
          .toInt();
    }
    if (_phase == SessionPhase.rest && _roundIndex < preset.rounds - 1) {
      _roundIndex += 1;
    }
    _secondsIntoPhase = 0;
    _phase = SessionPhase.active;
    _phaseDuration = preset.roundDurationSec;
    _paused = true;
    _scheduler.pause();
    _isRunning = false;
    _finalResult = null;
    _emitStimulus(force: true);
    _updateSnapshot();
  }

  void skipForward() {
    if (_phase == SessionPhase.end) return;
    _paused = true;
    _scheduler.pause();
    if (_phase == SessionPhase.countdown) {
      _enterActiveRound(emitStimulus: true, playAudio: false);
      _updateSnapshot();
      return;
    }
    if (_phase == SessionPhase.active) {
      final isLastRound = _roundIndex >= preset.rounds - 1;
      if (isLastRound) {
        _endSession();
      } else if (preset.restDurationSec == 0) {
        _roundIndex += 1;
        _enterActiveRound(emitStimulus: true, playAudio: false);
      } else {
        _phase = SessionPhase.rest;
        _secondsIntoPhase = 0;
        _phaseDuration = preset.restDurationSec;
      }
      _updateSnapshot();
      return;
    }
    if (_phase == SessionPhase.rest) {
      final isBeforeLastRound = _roundIndex < preset.rounds - 1;
      if (isBeforeLastRound) {
        _roundIndex += 1;
        _enterActiveRound(emitStimulus: true, playAudio: false);
      } else {
        _endSession();
      }
      _updateSnapshot();
    }
  }

  SessionResult finishEarly() {
    _endSession();
    _updateSnapshot();
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
    if (_paused || _phase == SessionPhase.end) return;
    if (_phase == SessionPhase.countdown &&
        preset.audioEnabled &&
        _lastTickAudioSecond != _elapsedSeconds) {
      _lastTickAudioSecond = _elapsedSeconds;
      unawaited(
          _audio.playTick(sessionSecond: _elapsedSeconds, phase: _phase.name));
    }
    _elapsedSeconds += 1;
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
    _recordCompletedRound();
    final isLastRound = _roundIndex >= preset.rounds - 1;
    if (isLastRound) {
      _endSession();
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

  void _enterActiveRound({required bool emitStimulus, bool playAudio = true}) {
    _phase = SessionPhase.active;
    _phaseDuration = preset.roundDurationSec;
    _secondsIntoPhase = 0;
    if (emitStimulus) {
      _emitStimulus(force: true);
    }
    if (playAudio &&
        preset.audioEnabled &&
        _lastRoundStartRound != _roundIndex) {
      _lastRoundStartRound = _roundIndex;
      unawaited(_audio.playRoundStart(
          sessionSecond: _elapsedSeconds, phase: _phase.name));
    }
  }

  void _emitStimulus({bool force = false}) {
    int number;
    final canAvoidRepeatNumber = preset.numberMax > preset.numberMin;
    do {
      number = randomInRange(_rng, preset.numberMin, preset.numberMax);
    } while (!force &&
        _lastStimulus != null &&
        canAvoidRepeatNumber &&
        _lastStimulus!.number == number);
    final palette = Palette.resolveWithContrast(
      preset.paletteId,
      highContrast: preset.highContrastPalette,
    );
    final activeIds =
        preset.activeColorIds?.map((value) => value.toLowerCase()).toSet();
    final paletteColors = palette.colors;
    final filteredColors = activeIds == null || activeIds.isEmpty
        ? paletteColors
        : paletteColors.where((color) {
            final id = color.toARGB32().toRadixString(16).toLowerCase();
            return activeIds.contains(id);
          }).toList();
    final availableColors =
        filteredColors.isEmpty ? paletteColors : filteredColors;
    Color color;
    final canAvoidRepeatColor = availableColors.length > 1;
    String colorId;
    do {
      color = availableColors[_rng.nextInt(availableColors.length)];
      colorId = color.toARGB32().toRadixString(16);
    } while (!force &&
        _lastStimulus != null &&
        canAvoidRepeatColor &&
        _lastStimulus!.colorId == colorId);
    final stimulus = Stimulus(
      timestampSec: _elapsedSeconds,
      colorId: colorId,
      number: number,
    );
    _lastStimulus = stimulus;
    _stimuli.add(stimulus);
    _snapshot = _snapshot.copyWith(
      currentNumber: number,
      currentColor: color,
    );
  }

  void _recordCompletedRound() {
    final duration = _secondsIntoPhase.clamp(0, preset.roundDurationSec);
    if (_roundDurations.length > _roundIndex) {
      _roundDurations[_roundIndex] = duration;
    } else {
      _roundDurations.add(duration);
    }
  }

  SessionResult _buildResult() {
    final roundsInt = _roundDurations.length.clamp(0, preset.rounds).toInt();
    final perRound = List<int>.from(_roundDurations.take(roundsInt));
    return SessionResult(
      completedAt: DateTime.now(),
      presetSnapshot: preset,
      roundsCompleted: roundsInt,
      perRoundDurationsSec: perRound,
      totalElapsedSec: _elapsedSeconds,
      stimuli: List.unmodifiable(_stimuli),
    );
  }

  void _endSession() {
    _phase = SessionPhase.end;
    _scheduler.pause();
    _paused = true;
    _isRunning = false;
    _finalResult = _buildResult();
    _invokeWakelock(_wakelockDisable);
  }

  void _updateSnapshot() {
    final phaseDuration = _phaseDuration ?? 0;
    final remainingRaw = phaseDuration - _secondsIntoPhase;
    final secondsRemaining = remainingRaw >= 0 ? remainingRaw : 0;
    final palette = Palette.resolveWithContrast(
      preset.paletteId,
      highContrast: preset.highContrastPalette,
    );
    _snapshot = _snapshot.copyWith(
      phase: _phase,
      secondsIntoPhase: _secondsIntoPhase,
      secondsRemainingInPhase: secondsRemaining,
      elapsedSeconds: _elapsedSeconds,
      roundIndex: _roundIndex,
      roundsTotal: preset.rounds,
      currentNumber: _snapshot.currentNumber,
      currentColor: _snapshot.currentColor ?? palette.countdownColor,
      isPaused: _paused,
      isLastRound: _roundIndex >= preset.rounds - 1,
    );
    notifyListeners();
  }

  void _invokeWakelock(Future<void> Function() toggle) {
    unawaited(
      Future<void>(() async {
        try {
          await toggle();
        } catch (_) {
          // Swallow platform errors in environments where wakelock channels are unavailable (e.g., tests).
        }
      }),
    );
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum SessionPhase { countdown, active, rest, end }

class SessionPreset {
  const SessionPreset({
    required this.rounds,
    required this.roundDurationSec,
    required this.restDurationSec,
    required this.changeIntervalSec,
    required this.numberMin,
    required this.numberMax,
    required this.paletteId,
    required this.countdownSec,
    required this.outdoorBoost,
    this.rngSeed,
    this.activeColorIds,
  });

  final int rounds;
  final int roundDurationSec;
  final int restDurationSec;
  final int changeIntervalSec;
  final int numberMin;
  final int numberMax;
  final String paletteId;
  final int countdownSec;
  final bool outdoorBoost;
  final int? rngSeed;
  final List<String>? activeColorIds;

  factory SessionPreset.defaults() {
    return const SessionPreset(
      rounds: 6,
      roundDurationSec: 45,
      restDurationSec: 15,
      changeIntervalSec: 1,
      numberMin: 1,
      numberMax: 9,
      paletteId: Palette.defaultPaletteId,
      countdownSec: 5,
      outdoorBoost: false,
      rngSeed: null,
      activeColorIds: null,
    );
  }

  SessionPreset copyWith({
    int? rounds,
    int? roundDurationSec,
    int? restDurationSec,
    int? changeIntervalSec,
    int? numberMin,
    int? numberMax,
    String? paletteId,
    int? countdownSec,
    bool? outdoorBoost,
    int? rngSeed,
    List<String>? activeColorIds,
  }) {
    return SessionPreset(
      rounds: rounds ?? this.rounds,
      roundDurationSec: roundDurationSec ?? this.roundDurationSec,
      restDurationSec: restDurationSec ?? this.restDurationSec,
      changeIntervalSec: changeIntervalSec ?? this.changeIntervalSec,
      numberMin: numberMin ?? this.numberMin,
      numberMax: numberMax ?? this.numberMax,
      paletteId: paletteId ?? this.paletteId,
      countdownSec: countdownSec ?? this.countdownSec,
      outdoorBoost: outdoorBoost ?? this.outdoorBoost,
      rngSeed: rngSeed ?? this.rngSeed,
      activeColorIds: activeColorIds ?? this.activeColorIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'rounds': rounds,
        'roundDurationSec': roundDurationSec,
        'restDurationSec': restDurationSec,
        'changeIntervalSec': changeIntervalSec,
        'numberMin': numberMin,
        'numberMax': numberMax,
        'paletteId': paletteId,
        'countdownSec': countdownSec,
        'outdoorBoost': outdoorBoost,
        'rngSeed': rngSeed,
        'activeColorIds': activeColorIds,
      };

  factory SessionPreset.fromJson(Map<String, dynamic> json) {
    return SessionPreset(
      rounds: json['rounds'] as int,
      roundDurationSec: json['roundDurationSec'] as int,
      restDurationSec: json['restDurationSec'] as int,
      changeIntervalSec: json['changeIntervalSec'] as int,
      numberMin: json['numberMin'] as int,
      numberMax: json['numberMax'] as int,
      paletteId: json['paletteId'] as String,
      countdownSec: json['countdownSec'] as int,
      outdoorBoost: json['outdoorBoost'] as bool? ?? false,
      rngSeed: json['rngSeed'] as int?,
      activeColorIds: (json['activeColorIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class Stimulus {
  Stimulus({
    required this.timestampMs,
    required this.colorId,
    required this.number,
  });

  final int timestampMs;
  final String colorId;
  final int number;

  Map<String, dynamic> toJson() => {
        'timestampMs': timestampMs,
        'colorId': colorId,
        'number': number,
      };

  factory Stimulus.fromJson(Map<String, dynamic> json) {
    return Stimulus(
      timestampMs: json['timestampMs'] as int,
      colorId: json['colorId'] as String,
      number: json['number'] as int,
    );
  }
}

class SessionResult {
  SessionResult({
    String? id,
    required this.completedAt,
    required this.presetSnapshot,
    required this.roundsCompleted,
    required this.perRoundDurationsSec,
    required this.totalElapsedSec,
    required this.stimuli,
  }) : id = id ?? _uuid.v4();

  final String id;
  final DateTime completedAt;
  final SessionPreset presetSnapshot;
  final int roundsCompleted;
  final List<int> perRoundDurationsSec;
  final int totalElapsedSec;
  final List<Stimulus> stimuli;

  Map<String, dynamic> toJson() => {
        'id': id,
        'completedAt': completedAt.toIso8601String(),
        'presetSnapshot': presetSnapshot.toJson(),
        'roundsCompleted': roundsCompleted,
        'perRoundDurationsSec': perRoundDurationsSec,
        'totalElapsedSec': totalElapsedSec,
        'stimuli': stimuli.map((s) => s.toJson()).toList(),
      };

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    return SessionResult(
      id: json['id'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      presetSnapshot: SessionPreset.fromJson(
        json['presetSnapshot'] as Map<String, dynamic>,
      ),
      roundsCompleted: json['roundsCompleted'] as int,
      perRoundDurationsSec: (json['perRoundDurationsSec'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      totalElapsedSec: json['totalElapsedSec'] as int,
      stimuli: (json['stimuli'] as List<dynamic>)
          .map((e) => Stimulus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Palette {
  const Palette({
    required this.id,
    required this.label,
    required this.colors,
    required this.countdownColor,
    required this.restColor,
    required this.textColor,
  });

  final String id;
  final String label;
  final List<Color> colors;
  final Color countdownColor;
  final Color restColor;
  final Color textColor;

  static const defaultPaletteId = 'sunrise';

  static const Map<String, Palette> palettes = {
    'basic': Palette(
      id: 'basic',
      label: 'Basic',
      colors: [
        Color(0xFF2E8E43), // green
        Color(0xFF1E88E5), // blue
        Color(0xFFD32F2F), // red
        Color(0xFFFBC02D), // yellow
        Color(0xFF8E24AA), // purple
        Color(0xFFFF7043), // orange
        Color(0xFF00897B), // teal
        Color(0xFFEC407A), // pink
      ],
      countdownColor: Color(0xFF111111),
      restColor: Color(0xFF2F2F2F),
      textColor: Colors.white,
    ),
    'sunrise': Palette(
      id: 'sunrise',
      label: 'Sunrise',
      colors: [
        Color(0xFFFE4A49),
        Color(0xFF2AB7CA),
        Color(0xFFFED766),
        Color(0xFF009FB7),
        Color(0xFFFFA552),
        Color(0xFFFA7921),
        Color(0xFF7F2982),
        Color(0xFF4062BB),
      ],
      countdownColor: Color(0xFF222831),
      restColor: Color(0xFF393E46),
      textColor: Colors.white,
    ),
    'field': Palette(
      id: 'field',
      label: 'Field',
      colors: [
        Color(0xFF00A878),
        Color(0xFF005377),
        Color(0xFFE4572E),
        Color(0xFF17BEBB),
        Color(0xFF7FB069),
        Color(0xFF4D9078),
        Color(0xFF2B2D42),
        Color(0xFFD4A373),
      ],
      countdownColor: Color(0xFF07393C),
      restColor: Color(0xFF1B512D),
      textColor: Colors.white,
    ),
    'contrast': Palette(
      id: 'contrast',
      label: 'Contrast',
      colors: [
        Color(0xFFFFD23F),
        Color(0xFFEE4266),
        Color(0xFF3CBBB1),
        Color(0xFF2A1E5C),
        Color(0xFF0CCE6B),
        Color(0xFFFE5F55),
        Color(0xFF7D7ABC),
        Color(0xFF1F7A8C),
      ],
      countdownColor: Color(0xFF1E1E24),
      restColor: Color(0xFF2E2E38),
      textColor: Colors.white,
    ),
  };

  static Palette resolve(String id) {
    return palettes[id] ?? palettes[defaultPaletteId]!;
  }

  Color boostedTextColor(bool outdoorBoost) {
    if (!outdoorBoost) return textColor;
    return textColor.withRed(255);
  }
}

class SessionSnapshot {
  const SessionSnapshot({
    required this.phase,
    required this.secondsIntoPhase,
    required this.secondsRemainingInPhase,
    required this.roundIndex,
    required this.roundsTotal,
    required this.currentNumber,
    required this.currentColor,
    required this.isPaused,
    required this.isLastRound,
  });

  final SessionPhase phase;
  final int secondsIntoPhase;
  final int secondsRemainingInPhase;
  final int roundIndex;
  final int roundsTotal;
  final int? currentNumber;
  final Color? currentColor;
  final bool isPaused;
  final bool isLastRound;

  SessionSnapshot copyWith({
    SessionPhase? phase,
    int? secondsIntoPhase,
    int? secondsRemainingInPhase,
    int? roundIndex,
    int? roundsTotal,
    int? currentNumber,
    Color? currentColor,
    bool? isPaused,
    bool? isLastRound,
  }) {
    return SessionSnapshot(
      phase: phase ?? this.phase,
      secondsIntoPhase: secondsIntoPhase ?? this.secondsIntoPhase,
      secondsRemainingInPhase:
          secondsRemainingInPhase ?? this.secondsRemainingInPhase,
      roundIndex: roundIndex ?? this.roundIndex,
      roundsTotal: roundsTotal ?? this.roundsTotal,
      currentNumber: currentNumber ?? this.currentNumber,
      currentColor: currentColor ?? this.currentColor,
      isPaused: isPaused ?? this.isPaused,
      isLastRound: isLastRound ?? this.isLastRound,
    );
  }
}

int randomInRange(Random rng, int min, int max) =>
    min + rng.nextInt((max - min) + 1);

extension SessionResultCsv on List<SessionResult> {
  String toCsv() {
    final buffer = StringBuffer(
      'id,completedAt,roundsCompleted,totalElapsedSec,palette,roundDurations\n',
    );
    for (final result in this) {
      buffer.writeln(
        '${result.id},'
        '${result.completedAt.toIso8601String()},'
        '${result.roundsCompleted},'
        '${result.totalElapsedSec},'
        '${result.presetSnapshot.paletteId},'
        '"${result.perRoundDurationsSec.join('|')}"',
      );
    }
    return buffer.toString();
  }
}

extension Serializable on SessionPreset {
  String encode() => jsonEncode(toJson());
}

extension SessionPresetDecode on String {
  SessionPreset toPreset() =>
      SessionPreset.fromJson(jsonDecode(this) as Map<String, dynamic>);
}

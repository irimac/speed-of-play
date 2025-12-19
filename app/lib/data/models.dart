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
    required this.largeSessionText,
    required this.highContrastPalette,
    required this.audioEnabled,
    this.activeColorIds,
    this.rngSeed,
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
  final bool largeSessionText;
  final bool highContrastPalette;
  final bool audioEnabled;
  final List<String>? activeColorIds;
  final int? rngSeed;

  static const _unset = Object();

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
      largeSessionText: false,
      highContrastPalette: false,
      audioEnabled: true,
      activeColorIds: null,
      rngSeed: null,
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
    bool? largeSessionText,
    bool? highContrastPalette,
    bool? audioEnabled,
    Object? activeColorIds = _unset,
    Object? rngSeed = _unset,
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
      largeSessionText: largeSessionText ?? this.largeSessionText,
      highContrastPalette: highContrastPalette ?? this.highContrastPalette,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      activeColorIds: activeColorIds == _unset
          ? this.activeColorIds
          : activeColorIds as List<String>?,
      rngSeed: rngSeed == _unset ? this.rngSeed : rngSeed as int?,
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
        'largeSessionText': largeSessionText,
        'highContrastPalette': highContrastPalette,
        'audioEnabled': audioEnabled,
        'activeColorIds': activeColorIds,
        'rngSeed': rngSeed,
      };

  factory SessionPreset.fromJson(Map<String, dynamic> json) {
    final rawActive = json['activeColorIds'] as List<dynamic>?;
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
      largeSessionText: json['largeSessionText'] as bool? ?? false,
      highContrastPalette: json['highContrastPalette'] as bool? ?? false,
      audioEnabled: json['audioEnabled'] as bool? ?? true,
      activeColorIds: rawActive?.map((value) => value.toString()).toList(),
      rngSeed: json['rngSeed'] as int?,
    );
  }
}

class Stimulus {
  Stimulus({
    required this.timestampSec,
    required this.colorId,
    required this.number,
  });

  final int timestampSec;
  final String colorId;
  final int number;

  Map<String, dynamic> toJson() => {
        'timestampSec': timestampSec,
        'colorId': colorId,
        'number': number,
      };

  factory Stimulus.fromJson(Map<String, dynamic> json) {
    return Stimulus(
      timestampSec: (json['timestampSec'] ?? json['timestampMs']) as int,
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

  static const defaultPaletteId = 'basic';

  static const Map<String, Palette> palettes = {
    'sunrise': Palette(
      id: 'sunrise',
      label: 'Sunrise',
      colors: [
        Color(0xFFFE4A49),
        Color(0xFF2AB7CA),
        Color(0xFFFED766),
        Color(0xFF009FB7),
        Color(0xFFF6AE2D),
        Color(0xFF6D597A),
        Color(0xFF355070),
        Color(0xFFFF9B71),
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
        Color(0xFF2E7D32),
        Color(0xFF6A994E),
        Color(0xFFBC4749),
        Color(0xFFF2E8CF),
      ],
      countdownColor: Color(0xFF07393C),
      restColor: Color(0xFF1B512D),
      textColor: Colors.white,
    ),
    'basic': Palette(
      id: 'basic',
      label: 'Basic',
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFFFD400),
        Color(0xFF0077FF),
        Color(0xFFE10600),
        Color(0xFF1B9E3C),
        Color(0xFFFF7A00),
        Color(0xFF000000),
        Color(0xFF9E9E9E),
      ],
      countdownColor: Color(0xFF111111),
      restColor: Color(0xFF222222),
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
        Color(0xFF0F4C5C),
        Color(0xFF1B998B),
        Color(0xFFED6A5A),
        Color(0xFF114B5F),
      ],
      countdownColor: Color(0xFF1E1E24),
      restColor: Color(0xFF2E2E38),
      textColor: Colors.white,
    ),
  };

  static Palette resolve(String id) {
    return palettes[id] ?? palettes[defaultPaletteId]!;
  }

  static Palette resolveWithContrast(String id, {required bool highContrast}) {
    if (highContrast && palettes.containsKey('contrast')) {
      return palettes['contrast']!;
    }
    return resolve(id);
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
    required this.elapsedSeconds,
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
  final int elapsedSeconds;
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
    int? elapsedSeconds,
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
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
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

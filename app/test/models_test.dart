import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/data/models.dart';

void main() {
  group('randomInRange', () {
    test('returns inclusive values within bounds', () {
      final rng = Random(42);
      for (var i = 0; i < 100; i++) {
        final value = randomInRange(rng, 1, 3);
        expect(value, inInclusiveRange(1, 3));
      }
    });
  });

  group('SessionPreset', () {
    test('encodes and decodes symmetrically', () {
      const preset = SessionPreset.defaults();
      final json = preset.toJson();
      final roundTrip = SessionPreset.fromJson(json);

      expect(roundTrip.rounds, preset.rounds);
      expect(roundTrip.roundDurationSec, preset.roundDurationSec);
      expect(roundTrip.restDurationSec, preset.restDurationSec);
      expect(roundTrip.changeIntervalSec, preset.changeIntervalSec);
      expect(roundTrip.numberMin, preset.numberMin);
      expect(roundTrip.numberMax, preset.numberMax);
      expect(roundTrip.paletteId, preset.paletteId);
      expect(roundTrip.countdownSec, preset.countdownSec);
      expect(roundTrip.outdoorBoost, preset.outdoorBoost);
      expect(roundTrip.rngSeed, preset.rngSeed);
    });
  });

  group('SessionResult', () {
    test('encodes and decodes symmetrically', () {
      final preset = SessionPreset.defaults();
      final stimuli = [
        Stimulus(timestampMs: 1, colorId: 'ff0000', number: 3),
        Stimulus(timestampMs: 2, colorId: '00ff00', number: 7),
      ];
      final result = SessionResult(
        completedAt: DateTime.parse('2024-01-01T12:00:00Z'),
        presetSnapshot: preset,
        roundsCompleted: 2,
        perRoundDurationsSec: const [45, 45],
        totalElapsedSec: 90,
        stimuli: stimuli,
      );

      final json = result.toJson();
      final roundTrip = SessionResult.fromJson(json);

      expect(roundTrip.roundsCompleted, result.roundsCompleted);
      expect(roundTrip.totalElapsedSec, result.totalElapsedSec);
      expect(roundTrip.perRoundDurationsSec, result.perRoundDurationsSec);
      expect(roundTrip.presetSnapshot.paletteId, result.presetSnapshot.paletteId);
      expect(roundTrip.presetSnapshot.rounds, result.presetSnapshot.rounds);
      expect(roundTrip.stimuli.length, result.stimuli.length);
      expect(roundTrip.stimuli.first.number, result.stimuli.first.number);
      expect(roundTrip.stimuli.last.colorId, result.stimuli.last.colorId);
    });

    test('CSV export renders expected fields', () {
      final preset = SessionPreset.defaults();
      final result = SessionResult(
        id: 'abc',
        completedAt: DateTime.parse('2024-01-01T12:00:00Z'),
        presetSnapshot: preset,
        roundsCompleted: 2,
        perRoundDurationsSec: const [45, 45],
        totalElapsedSec: 90,
        stimuli: const [],
      );

      final csv = [result].toCsv();

      expect(csv.split('\n').first, 'id,completedAt,roundsCompleted,totalElapsedSec,palette,roundDurations');
      expect(
        csv,
        contains('abc,2024-01-01T12:00:00.000Z,2,90,${preset.paletteId},"45|45"'),
      );
    });
  });
}

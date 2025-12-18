import 'package:flutter_test/flutter_test.dart';
import 'package:speed_of_play/services/audio_cue_player.dart';

class _SpyBackend implements AudioBackend {
  int setAssetCalls = 0;
  int seekCalls = 0;
  int playCalls = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> play() async {
    playCalls++;
  }

  @override
  Future<void> seek(Duration position) async {
    seekCalls++;
  }

  @override
  Future<void> setAsset(String assetPath) async {
    setAssetCalls++;
  }
}

void main() {
  test('AudioCuePlayer preloads only once and play does not reload', () async {
    final tick = _SpyBackend();
    final start = _SpyBackend();
    final player = AudioCuePlayer(tickBackend: tick, roundStartBackend: start);

    await player.ensureLoaded();
    await player.ensureLoaded();

    expect(tick.setAssetCalls, 1);
    expect(start.setAssetCalls, 1);

    await player.playTick();
    await player.playRoundStart();

    expect(tick.seekCalls, 1);
    expect(tick.playCalls, 1);
    expect(start.seekCalls, 1);
    expect(start.playCalls, 1);

    await player.dispose();
  });
}

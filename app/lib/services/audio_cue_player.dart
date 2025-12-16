import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioCuePlayer {
  AudioCuePlayer();

  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _roundStartPlayer = AudioPlayer();
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      await Future.wait([
        _tickPlayer.setAsset('assets/audio/tick.wav'),
        _roundStartPlayer.setAsset('assets/audio/round_start.wav'),
      ]);
      _loaded = true;
    } catch (err) {
      debugPrint('Audio preload failed: $err');
    }
  }

  Future<void> playTick() async {
    if (!_loaded) return;
    await _tickPlayer.seek(Duration.zero);
    await _tickPlayer.play();
  }

  Future<void> playRoundStart() async {
    if (!_loaded) return;
    await _roundStartPlayer.seek(Duration.zero);
    await _roundStartPlayer.play();
  }

  Future<void> dispose() async {
    await Future.wait([
      _tickPlayer.dispose(),
      _roundStartPlayer.dispose(),
    ]);
  }
}

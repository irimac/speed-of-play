import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

abstract class AudioBackend {
  Future<void> setAsset(String assetPath);
  Future<void> seek(Duration position);
  Future<void> play();
  Future<void> dispose();
}

class JustAudioBackend implements AudioBackend {
  JustAudioBackend() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> setAsset(String assetPath) => _player.setAsset(assetPath);

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> dispose() => _player.dispose();
}

class AudioCuePlayer {
  AudioCuePlayer({
    AudioBackend? tickBackend,
    AudioBackend? roundStartBackend,
  })  : _tickBackend = tickBackend ?? JustAudioBackend(),
        _roundStartBackend = roundStartBackend ?? JustAudioBackend() {
    assert(() {
      _trace = <AudioEventTraceEntry>[];
      return true;
    }());
  }

  final AudioBackend _tickBackend;
  final AudioBackend _roundStartBackend;
  bool _loaded = false;
  Future<void>? _loadFuture;
  List<AudioEventTraceEntry>? _trace;
  static const int _traceLimit = 50;

  Future<void> ensureLoaded() {
    _loadFuture ??= _load();
    return _loadFuture!;
  }

  Future<void> _load() async {
    if (_loaded) return;
    try {
      await Future.wait([
        _tickBackend.setAsset('assets/audio/tick.wav'),
        _roundStartBackend.setAsset('assets/audio/round_start.wav'),
      ]);
      _loaded = true;
    } catch (err) {
      debugPrint('Audio preload failed: $err');
    }
  }

  Future<void> playTick({int? sessionSecond, String? phase}) async {
    if (!_loaded) {
      await ensureLoaded();
      if (!_loaded) return;
    }
    await _tickBackend.seek(Duration.zero);
    await _tickBackend.play();
    _recordTrace('tick', sessionSecond, phase);
  }

  Future<void> playRoundStart({int? sessionSecond, String? phase}) async {
    if (!_loaded) {
      await ensureLoaded();
      if (!_loaded) return;
    }
    await _roundStartBackend.seek(Duration.zero);
    await _roundStartBackend.play();
    _recordTrace('roundStart', sessionSecond, phase);
  }

  Future<void> dispose() async {
    await Future.wait([
      _tickBackend.dispose(),
      _roundStartBackend.dispose(),
    ]);
  }

  List<AudioEventTraceEntry> currentTrace() {
    final t = _trace;
    if (t == null) return const [];
    return List<AudioEventTraceEntry>.unmodifiable(t);
  }

  void _recordTrace(String eventType, int? sessionSecond, String? phase) {
    final t = _trace;
    if (t == null || sessionSecond == null) return;
    if (t.length >= _traceLimit) {
      t.removeAt(0);
    }
    t.add(
      AudioEventTraceEntry(
        sessionSecond: sessionSecond,
        eventType: eventType,
        phase: phase,
      ),
    );
  }
}

class AudioEventTraceEntry {
  const AudioEventTraceEntry({
    required this.sessionSecond,
    required this.eventType,
    this.phase,
  });

  final int sessionSecond;
  final String eventType;
  final String? phase;
}

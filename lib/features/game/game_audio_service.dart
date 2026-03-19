import 'package:audioplayers/audioplayers.dart';

class GameAudioService {
  static const _collectPath = 'sounds/game/collect.wav';
  static const _hitPath = 'sounds/game/hit.wav';
  static const _gameOverPath = 'sounds/game/game_over.wav';

  final AudioPlayer _collectPlayer = AudioPlayer();
  final AudioPlayer _hitPlayer = AudioPlayer();
  final AudioPlayer _gameOverPlayer = AudioPlayer();

  bool _disposed = false;

  Future<void> init() async {
    await Future.wait([
      _collectPlayer.setReleaseMode(ReleaseMode.stop),
      _hitPlayer.setReleaseMode(ReleaseMode.stop),
      _gameOverPlayer.setReleaseMode(ReleaseMode.stop),
    ]);
  }

  Future<void> playCollect({bool premium = false}) async {
    final volume = premium ? 0.9 : 0.75;
    await _play(_collectPlayer, _collectPath, volume);
  }

  Future<void> playHit({bool hardHit = false}) async {
    final volume = hardHit ? 0.95 : 0.82;
    await _play(_hitPlayer, _hitPath, volume);
  }

  Future<void> playGameOver() async {
    await _play(_gameOverPlayer, _gameOverPath, 0.95);
  }

  Future<void> _play(AudioPlayer player, String path, double volume) async {
    if (_disposed) return;
    try {
      await player.stop();
      await player.play(AssetSource(path), volume: volume);
    } catch (_) {
      // Keep gameplay resilient if device audio backend fails.
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await Future.wait([
      _collectPlayer.dispose(),
      _hitPlayer.dispose(),
      _gameOverPlayer.dispose(),
    ]);
  }
}

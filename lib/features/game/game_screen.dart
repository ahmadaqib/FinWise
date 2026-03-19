import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import 'game_audio_service.dart';
import 'game_ffi_bridge.dart';

class GameScreen extends StatefulWidget {
  final double difficulty; // 0.0 to 1.0

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const String _highScoreKey = 'game_high_score_v1';

  late final GameFFIBridge _bridge;
  late final GameAudioService _audio;
  late final ffi.Pointer<GameState> _state;
  late final Ticker _ticker;

  SharedPreferences? _prefs;
  int _highScore = 0;

  double _inputX = 0.5;
  double _animationTime = 0;
  Duration _lastElapsed = Duration.zero;
  Duration _recordPulseUntil = Duration.zero;
  int _previousScore = 0;
  int _previousHealth = 100;
  bool _previousGameOver = false;

  Duration _lastCollectSfxAt = Duration.zero;
  Duration _lastHitSfxAt = Duration.zero;
  Duration _lastGameOverSfxAt = Duration.zero;

  @override
  void initState() {
    super.initState();
    _bridge = GameFFIBridge();
    _audio = GameAudioService();
    _state = _bridge.createGameState();
    _bridge.initGame(_state);
    _syncStateCacheFromEngine();

    _ticker = createTicker(_onTick);
    _ticker.start();

    unawaited(_audio.init());
    unawaited(_loadHighScore());
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _highScore = prefs.getInt(_highScoreKey) ?? 0;
    });
  }

  void _persistHighScore(int score) {
    final prefs = _prefs;
    if (prefs != null) {
      unawaited(prefs.setInt(_highScoreKey, score));
      return;
    }
    unawaited(_persistHighScoreAsync(score));
  }

  Future<void> _persistHighScoreAsync(int score) async {
    final prefs = await SharedPreferences.getInstance();
    _prefs ??= prefs;
    await prefs.setInt(_highScoreKey, score);
  }

  void _syncStateCacheFromEngine() {
    final gameState = _state.ref;
    _previousScore = gameState.score;
    _previousHealth = gameState.health;
    _previousGameOver = gameState.isGameOver;
  }

  void _playCollectFeedback(Duration elapsed, {bool premium = false}) {
    final cooldown = premium
        ? const Duration(milliseconds: 45)
        : const Duration(milliseconds: 85);
    if (elapsed - _lastCollectSfxAt < cooldown) return;

    _lastCollectSfxAt = elapsed;
    unawaited(_audio.playCollect(premium: premium));
    unawaited(HapticFeedback.selectionClick());
  }

  void _playHitFeedback(Duration elapsed, {bool hardHit = false}) {
    final cooldown = hardHit
        ? const Duration(milliseconds: 130)
        : const Duration(milliseconds: 180);
    if (elapsed - _lastHitSfxAt < cooldown) return;

    _lastHitSfxAt = elapsed;
    unawaited(_audio.playHit(hardHit: hardHit));
    if (hardHit) {
      unawaited(HapticFeedback.heavyImpact());
    } else {
      unawaited(HapticFeedback.mediumImpact());
    }
  }

  void _playGameOverFeedback(Duration elapsed) {
    if (elapsed - _lastGameOverSfxAt < const Duration(milliseconds: 500)) {
      return;
    }
    _lastGameOverSfxAt = elapsed;
    unawaited(_audio.playGameOver());
    unawaited(HapticFeedback.vibrate());
  }

  double _safeInputClamp(double normalizedX) {
    final radius = _state.ref.playerRadius.clamp(0.0, 0.49).toDouble();
    final maxX = (1.0 - radius).clamp(radius, 1.0).toDouble();
    return normalizedX.clamp(radius, maxX).toDouble();
  }

  void _updateInputFromLocalPosition(Offset localPosition) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || renderObject.size.width <= 0) return;

    final normalizedX = localPosition.dx / renderObject.size.width;
    setState(() {
      _inputX = _safeInputClamp(normalizedX);
    });
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final dt =
        (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
    _lastElapsed = elapsed;
    _animationTime = elapsed.inMilliseconds / 1000.0;

    if (dt > 0.1) return; // Cap dt for stability

    _bridge.updateGame(_state, dt, _inputX, widget.difficulty);

    final gameState = _state.ref;
    final score = gameState.score;
    final health = gameState.health;
    final isGameOver = gameState.isGameOver;
    final scoreDelta = score - _previousScore;
    final healthDelta = health - _previousHealth;

    if (scoreDelta > 0) {
      _playCollectFeedback(elapsed, premium: scoreDelta >= 20);
    }
    if (healthDelta < 0) {
      _playHitFeedback(elapsed, hardHit: healthDelta <= -25);
    }
    if (!_previousGameOver && isGameOver) {
      _playGameOverFeedback(elapsed);
    }

    _previousScore = score;
    _previousHealth = health;
    _previousGameOver = isGameOver;

    if (score > _highScore) {
      _highScore = score;
      _recordPulseUntil = elapsed + const Duration(seconds: 2);
      _persistHighScore(score);
    }

    setState(() {});
  }

  void _restartGame() {
    _bridge.initGame(_state);
    _syncStateCacheFromEngine();
    _lastElapsed = Duration.zero;
    _inputX = _safeInputClamp(0.5);
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    unawaited(_audio.dispose());
    _bridge.freeGameState(_state);
    super.dispose();
  }

  TextStyle _pixelStyle({required double size, Color color = Colors.white}) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      height: 1.35,
      letterSpacing: 0.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final GameState gameState = _state.ref;
    final bool showRecordPulse = _lastElapsed < _recordPulseUntil;

    return Scaffold(
      backgroundColor: const Color(0xFF05070F),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) =>
            _updateInputFromLocalPosition(details.localPosition),
        onPanStart: (details) =>
            _updateInputFromLocalPosition(details.localPosition),
        onPanUpdate: (details) =>
            _updateInputFromLocalPosition(details.localPosition),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF11173A), Color(0xFF05070F)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: RetroGridPainter(time: _animationTime),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: GamePainter(
                  state: gameState,
                  animationTime: _animationTime,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'SCORE',
                            value: '${gameState.score}',
                            accent: const Color(0xFF58F6FF),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            label: 'HIGH',
                            value: '$_highScore',
                            accent: const Color(0xFFFFD166),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildHealthBar(gameState.health),
                    const SizedBox(height: 10),
                    Text(
                      'DRAG / TAP UNTUK GERAK',
                      style: _pixelStyle(size: 8, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'LEVEL ${(widget.difficulty * 9 + 1).round()}',
                      style: _pixelStyle(size: 8, color: Colors.white60),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'HIJAU + | MERAH - | ORANYE -- | CYAN ++',
                      style: _pixelStyle(size: 7, color: Colors.white54),
                    ),
                    if (showRecordPulse) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F5B35),
                          border: Border.all(
                            color: const Color(0xFF7DF7A8),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'NEW HIGH SCORE!',
                          style: _pixelStyle(
                            size: 8,
                            color: const Color(0xFFB7FFD0),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (gameState.isGameOver) _buildGameOver(gameState.score),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.85), width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _pixelStyle(size: 7, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(value, style: _pixelStyle(size: 12, color: accent)),
        ],
      ),
    );
  }

  Widget _buildHealthBar(int health) {
    const totalSegments = 10;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: List.generate(totalSegments, (index) {
          final threshold = (index + 1) * 10;
          final active = health >= threshold;
          final segmentColor = Color.lerp(
            AppColors.danger,
            AppColors.success,
            index / (totalSegments - 1),
          )!;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: active ? segmentColor : Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGameOver(int score) {
    final bool isNewRecord = score >= _highScore && score > 0;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.72),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF111424),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF58F6FF), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x402CF3FF),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GAME OVER',
                    style: _pixelStyle(
                      size: 18,
                      color: const Color(0xFFFF8E8E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'SCORE $score',
                    style: _pixelStyle(size: 10, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'HIGH $_highScore',
                    style: _pixelStyle(
                      size: 10,
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                  if (isNewRecord) ...[
                    const SizedBox(height: 12),
                    Text(
                      'NEW RECORD!',
                      style: _pixelStyle(
                        size: 9,
                        color: const Color(0xFF98FFBF),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _restartGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2CF3FF),
                        foregroundColor: const Color(0xFF061018),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'RESTART',
                        style: _pixelStyle(
                          size: 9,
                          color: const Color(0xFF061018),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 220,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54, width: 2),
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'EXIT',
                        style: _pixelStyle(size: 9, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RetroGridPainter extends CustomPainter {
  final double time;

  const RetroGridPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * 0.2;
    final centerX = size.width / 2;

    final linePaint = Paint()..strokeWidth = 1;

    final horizontalShift = (time * 100) % 30;
    for (double y = horizon - 30; y <= size.height + 30; y += 30) {
      final normalized = ((y - horizon) / (size.height - horizon)).clamp(
        0.0,
        1.0,
      );
      linePaint.color = const Color(
        0xFF2CF3FF,
      ).withValues(alpha: 0.05 + normalized * 0.25);
      canvas.drawLine(
        Offset(0, y + horizontalShift),
        Offset(size.width, y + horizontalShift),
        linePaint,
      );
    }

    linePaint.color = const Color(0xFF2CF3FF).withValues(alpha: 0.12);
    for (double x = -size.width; x <= size.width * 2; x += 42) {
      canvas.drawLine(
        Offset(centerX, horizon),
        Offset(x, size.height),
        linePaint,
      );
    }

    final starPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 60; i++) {
      final nx = ((i * 83) % 997) / 997;
      final speed = 6 + (i % 5) * 2;
      final ny = (((i * 47) + time * speed * 18) % 320) / 320;
      final twinkle = (math.sin(time * 2 + i * 0.35) + 1) / 2;
      final opacity = 0.2 + twinkle * 0.6;

      starPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(nx * size.width, ny * horizon),
        0.8 + (i % 3) * 0.35,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RetroGridPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class GamePainter extends CustomPainter {
  final GameState state;
  final double animationTime;

  const GamePainter({required this.state, required this.animationTime});

  @override
  void paint(Canvas canvas, Size size) {
    final playerCenter = Offset(
      state.playerX * size.width,
      state.playerY * size.height,
    );
    final playerRadius = state.playerRadius * size.width;

    final playerGlow = Paint()
      ..color = const Color(0xFF57F6FF).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(playerCenter, playerRadius * 1.6, playerGlow);

    final bodyRect = Rect.fromCenter(
      center: playerCenter,
      width: playerRadius * 2.2,
      height: playerRadius * 1.4,
    );

    final playerFill = Paint()..color = Colors.white;
    final playerOutline = Paint()
      ..color = const Color(0xFF2CF3FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final playerShape = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(3),
    );
    canvas.drawRRect(playerShape, playerFill);
    canvas.drawRRect(playerShape, playerOutline);

    final trailPaint = Paint()
      ..color = const Color(0xFF5BF7FF).withValues(alpha: 0.25)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final trailWave = math.sin(animationTime * 14) * 3;
    canvas.drawLine(
      playerCenter.translate(-playerRadius * 0.7, playerRadius * 0.2),
      playerCenter.translate(
        -playerRadius * 1.1,
        playerRadius * 1.5 + trailWave,
      ),
      trailPaint,
    );
    canvas.drawLine(
      playerCenter.translate(playerRadius * 0.7, playerRadius * 0.2),
      playerCenter.translate(
        playerRadius * 1.1,
        playerRadius * 1.5 - trailWave,
      ),
      trailPaint,
    );

    for (int i = 0; i < kGameMaxObstacles; i++) {
      final obs = state.obstacles[i];
      if (!obs.active) continue;

      final center = Offset(obs.x * size.width, obs.y * size.height);
      final radius = obs.radius * size.width;
      final type = obs.type;
      final baseColor = switch (type) {
        0 => AppColors.success,
        1 => AppColors.danger,
        2 => const Color(0xFFFF7A3D),
        3 => const Color(0xFF58F6FF),
        _ => Colors.white,
      };

      final obsGlow = Paint()
        ..color = baseColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(center, radius * 1.5, obsGlow);

      final streakPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.45)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final streakLength = type == 2 ? 3.6 : 2.8;
      canvas.drawLine(
        center.translate(0, -radius * streakLength),
        center,
        streakPaint,
      );

      if (type == 0) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(math.pi / 4);
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: radius * 1.8,
          height: radius * 1.8,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          Paint()..color = baseColor,
        );
        final plusPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(-radius * 0.3, 0),
          Offset(radius * 0.3, 0),
          plusPaint,
        );
        canvas.drawLine(
          Offset(0, -radius * 0.3),
          Offset(0, radius * 0.3),
          plusPaint,
        );
        canvas.restore();
      } else if (type == 1) {
        canvas.drawCircle(center, radius, Paint()..color = baseColor);
        final xPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          center.translate(-radius * 0.45, -radius * 0.45),
          center.translate(radius * 0.45, radius * 0.45),
          xPaint,
        );
        canvas.drawLine(
          center.translate(radius * 0.45, -radius * 0.45),
          center.translate(-radius * 0.45, radius * 0.45),
          xPaint,
        );
      } else if (type == 2) {
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx - radius * 0.92, center.dy + radius * 0.92)
          ..lineTo(center.dx + radius * 0.92, center.dy + radius * 0.92)
          ..close();
        canvas.drawPath(path, Paint()..color = baseColor);
        final warningPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          center.translate(0, -radius * 0.35),
          center.translate(0, radius * 0.25),
          warningPaint,
        );
        canvas.drawCircle(
          center.translate(0, radius * 0.45),
          radius * 0.08,
          Paint()..color = Colors.white,
        );
      } else {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate((animationTime * 1.8) + (i * 0.3));
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: radius * 1.9,
          height: radius * 1.9,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = baseColor,
        );
        canvas.restore();
        canvas.drawCircle(
          center,
          radius * 0.34,
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}

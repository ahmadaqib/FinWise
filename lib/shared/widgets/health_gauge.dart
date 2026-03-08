import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_text_styles.dart';

class HealthGauge extends StatefulWidget {
  final int score;
  final String label;

  const HealthGauge({super.key, required this.score, required this.label});

  @override
  State<HealthGauge> createState() => _HealthGaugeState();
}

class _HealthGaugeState extends State<HealthGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(HealthGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation =
          Tween<double>(
            begin: _animation.value,
            end: widget.score / 100,
          ).animate(
            CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score, bool isDark) {
    if (score >= 75) {
      return isDark ? const Color(0xFF6EDC98) : AppColors.success;
    }
    if (score >= 50) {
      return isDark ? const Color(0xFFE5B567) : AppColors.warning;
    }
    return isDark ? const Color(0xFFFCA5A5) : AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.darkSubtle : AppColors.surfaceSubtle;
    final scoreColor = _getScoreColor(widget.score, isDark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 160,
          height: 90, // Half circle height approx
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _GaugePainter(
                  progress: _animation.value,
                  trackColor: trackColor,
                  progressColor: scoreColor,
                  strokeWidth: 16,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      '${(_animation.value * 100).toInt()}',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: scoreColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _GaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    // Track arc
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // We draw from 180 degrees (pi) to 0 degrees, sweep is pi
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159, // pi
      3.14159, // pi
      false,
      trackPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159, // pi
      3.14159 * progress, // pi * progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

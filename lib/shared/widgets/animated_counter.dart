import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../providers/visibility_provider.dart';

class AnimatedCounter extends ConsumerWidget {
  final double value;
  final String Function(double)? formatter;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(amountVisibilityProvider);
    final textStyle =
        style ?? AppTextStyles.monoLarge.copyWith(color: AppColors.primary);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: AppAnimations.easeOut,
      builder: (context, currentValue, child) {
        final text = formatter != null
            ? formatter!(currentValue)
            : currentValue.toStringAsFixed(0);

        if (!isVisible) {
          final prefix = text.startsWith('Rp') ? 'Rp ' : '';
          return Text('$prefix••••••', style: textStyle);
        }

        return Text(text, style: textStyle);
      },
      // Using an implicit placeholder for initial frame
      child: const SizedBox.shrink(),
    );
  }
}

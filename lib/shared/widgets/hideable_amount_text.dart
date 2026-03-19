import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/visibility_provider.dart';

class HideableAmountText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final int maskLength;

  const HideableAmountText({
    super.key,
    required this.text,
    this.style,
    this.maskLength = 6,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(amountVisibilityProvider);
    
    if (!isVisible) {
      final dots = '•' * maskLength;
      // Handle "Rp 1.000.000" format
      if (text.startsWith('Rp')) {
        return Text('Rp $dots', style: style);
      }
      return Text(dots, style: style);
    }
    
    return Text(text, style: style);
  }
}

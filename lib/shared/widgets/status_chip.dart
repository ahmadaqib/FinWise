import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

enum ChipStatus { success, warning, danger, info, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipStatus status;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.status,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color fgColor;
    Color bgColor;

    switch (status) {
      case ChipStatus.success:
        fgColor = isDark
            ? const Color(0xFF6EDC98)
            : const Color(0xFF3D7A5E); // Enhanced contrast dark
        bgColor = isDark ? const Color(0xFF243B30) : const Color(0xFFEDF7F2);
        break;
      case ChipStatus.warning:
        fgColor = isDark ? const Color(0xFFE5B567) : const Color(0xFFB07D2E);
        bgColor = isDark ? const Color(0xFF4B391C) : const Color(0xFFFDF6E7);
        break;
      case ChipStatus.danger:
        fgColor = isDark
            ? const Color(0xFFFCA5A5)
            : const Color(0xFFA33030); // Subdued red light, bright red dark
        bgColor = isDark ? const Color(0xFF4A1F1F) : const Color(0xFFFDEEED);
        break;
      case ChipStatus.info:
        fgColor = isDark
            ? const Color(0xFF93C5FD)
            : const Color(0xFF2D5186); // Soft blue
        bgColor = isDark ? const Color(0xFF192A44) : const Color(0xFFEEF2F8);
        break;
      case ChipStatus.neutral:
        fgColor = isDark
            ? const Color(0xFFA1A1A5)
            : const Color(0xFF5C5C5C); // Muted
        bgColor = isDark ? const Color(0xFF2C2C2F) : const Color(0xFFEEF2F8);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fgColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';

class FlatCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  // final bool hasBorder;
  final Color? backgroundColor;

  const FlatCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
  });

  @override
  State<FlatCard> createState() => _FlatCardState();
}

class _FlatCardState extends State<FlatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBg = AppColors.surfaceCard;
    final bgColor = widget.backgroundColor ?? defaultBg;

    Widget cardWidget = AnimatedContainer(
      duration: AppAnimations.fast,
      decoration: BoxDecoration(
        color: _isHovered
            ? Color.alphaBlend(Colors.black.withValues(alpha: 0.02), bgColor)
            : bgColor,
        borderRadius: BorderRadius.circular(8),
        border: null, // No borders in Flat Design
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      cardWidget = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          behavior: HitTestBehavior.opaque,
          child: ScaleTransition(scale: _scaleAnimation, child: cardWidget),
        ),
      );
    }

    return cardWidget;
  }
}

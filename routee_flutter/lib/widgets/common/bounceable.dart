import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bounceable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;
  final Duration duration;
  final bool useHaptic;

  const Bounceable({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.94,
    this.duration = const Duration(milliseconds: 100),
    this.useHaptic = true,
  });

  @override
  State<Bounceable> createState() => _BounceableState();
}

class _BounceableState extends State<Bounceable> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) async {
    if (widget.useHaptic) {
      HapticFeedback.lightImpact();
    }
    try {
      await _controller.forward().orCancel;
      await _controller.reverse().orCancel;
    } catch (_) {}
    if (mounted) {
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: IgnorePointer(
          child: widget.child,
        ),
      ),
    );
  }
}

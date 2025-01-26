import 'package:flutter/material.dart';

enum AnimationType { fade, scale, slide }

class AnimatedWidgetWrapper extends StatefulWidget {
  final Widget child;
  final AnimationType animationType;
  final Duration duration;
  final Curve curve;
  final Offset? slideOffset; // Only for slide animation
  final double scaleBegin; // Only for scale animation

  const AnimatedWidgetWrapper({
    Key? key,
    required this.child,
    this.animationType = AnimationType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.slideOffset = const Offset(0, 0.1),
    this.scaleBegin = 0.8,
  }) : super(key: key);

  @override
  State<AnimatedWidgetWrapper> createState() => _AnimatedWidgetWrapperState();
}

class _AnimatedWidgetWrapperState extends State<AnimatedWidgetWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    switch (widget.animationType) {
      case AnimationType.fade:
        _fadeAnimation =
            CurvedAnimation(parent: _controller, curve: widget.curve);
        break;
      case AnimationType.scale:
        _scaleAnimation = Tween<double>(
          begin: widget.scaleBegin,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
        break;
      case AnimationType.slide:
        _slideAnimation = Tween<Offset>(
          begin: widget.slideOffset ?? Offset.zero,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
        break;
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (widget.animationType) {
          case AnimationType.fade:
            return Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            );
          case AnimationType.scale:
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          case AnimationType.slide:
            return SlideTransition(
              position: _slideAnimation,
              child: child,
            );
          default:
            return child!;
        }
      },
      child: widget.child,
    );
  }
}


class FadeInTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeInTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<FadeInTransition> createState() => _FadeInTransitionState();
}

class _FadeInTransitionState extends State<FadeInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1), // Slightly below its final position
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
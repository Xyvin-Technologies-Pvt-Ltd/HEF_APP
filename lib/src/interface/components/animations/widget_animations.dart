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


class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool fadeIn;
  final bool slideIn;
  final bool scaleIn;
  final Offset slideOffset;
  final double initialScale;
  final Curve curve;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.fadeIn = true,
    this.slideIn = true,
    this.scaleIn = true,
    this.slideOffset = const Offset(0.0, 0.25),
    this.initialScale = 0.95,
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: widget.fadeIn ? 0.0 : 1.0,
      end: 1.0,
    ).animate(curved);

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: widget.slideIn ? widget.slideOffset : Offset.zero,
      end: Offset.zero,
    ).animate(curved);

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: widget.scaleIn ? widget.initialScale : 1.0,
      end: 1.0,
    ).animate(curved);

    // Add delay if specified
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
        Widget current = widget.child;

        if (widget.fadeIn) {
          current = FadeTransition(
            opacity: _fadeAnimation,
            child: current,
          );
        }

        if (widget.slideIn) {
          current = SlideTransition(
            position: _slideAnimation,
            child: current,
          );
        }

        if (widget.scaleIn) {
          current = Transform.scale(
            scale: _scaleAnimation.value,
            child: current,
          );
        }

        return current;
      },
    );
  }
}
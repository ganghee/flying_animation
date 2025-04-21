import 'package:flutter/material.dart';

import 'single_flying_widget.dart';

/// A widget that creates a flying animation effect for any child widget.
///
/// This widget allows you to create a flying animation where a widget
/// appears to fly up from its original position while optionally shaking
/// and fading out. It's commonly used for effects like "like" animations
/// or other celebratory UI elements.
///
/// Example:
/// ```dart
/// FlyingWidget(
///   coverWidget: Icon(Icons.favorite, color: Colors.red),
///   child: Icon(Icons.favorite, color: Colors.red),
///   animationController: animationController,
///   flyHeight: 200.0,
///   isShake: true,
/// )
/// ```
class FlyingWidget extends StatefulWidget {
  /// The widget that stays in place while the child flies away.
  /// If null, the child will fly from its current position.
  final Widget? coverWidget;

  /// Whether the flying animation should start from the top of the cover widget.
  /// If false, it starts from the center.
  final bool isTopStart;

  /// The maximum height the widget will fly to before disappearing.
  final double flyHeight;

  /// Whether the widget should shake during the animation.
  final bool isShake;

  /// The controller for the flying animation.
  /// Use this to control when the animation starts and stops.
  final AnimationController animationController;

  /// The widget that will be animated to fly away.
  final Widget child;

  const FlyingWidget({
    super.key,
    this.coverWidget,
    this.flyHeight = 100,
    this.isTopStart = false,
    this.isShake = true,
    required this.animationController,
    required this.child,
  });

  @override
  State<FlyingWidget> createState() => _FlyingWidgetState();
}

class _FlyingWidgetState extends State<FlyingWidget>
    with TickerProviderStateMixin {
  /// Key used to get the size of the cover widget.
  final GlobalKey _coverWidgetKey = GlobalKey();

  @override
  void initState() {
    _initializeAnimationController();
    super.initState();
  }

  void _initializeAnimationController() {
    final duration = widget.animationController.duration;
    if (duration == null || duration.inMilliseconds == 0) {
      widget.animationController.duration = const Duration(seconds: 1);
    }

    widget.animationController.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status.isAnimating) {
      _createAndShowFlyingAnimation();
    }
  }

  void _createAndShowFlyingAnimation() {
    final flyAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationController.duration,
    );

    flyAnimationController.forward();
    final overlayEntry = _createFlyOverlay(flyAnimationController);
    Overlay.of(context).insert(overlayEntry);

    _scheduleOverlayRemoval(overlayEntry, flyAnimationController);
  }

  void _scheduleOverlayRemoval(
    OverlayEntry overlayEntry,
    AnimationController flyAnimationController,
  ) {
    final duration =
        widget.animationController.duration ?? const Duration(seconds: 1);
    Future.delayed(duration, () {
      overlayEntry.remove();
      overlayEntry.dispose();
      flyAnimationController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.coverWidget == null
        ? widget.child
        : Builder(
            key: _coverWidgetKey,
            builder: (BuildContext context) => widget.coverWidget!,
          );
  }

  OverlayEntry _createFlyOverlay(AnimationController flyAnimationController) {
    final coverRenderBox =
        _coverWidgetKey.currentContext?.findRenderObject() as RenderBox?;
    final coverWidgetOffset = coverRenderBox?.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SingleFlyingWidget(
            coverWidgetKey: _coverWidgetKey,
            coverWidgetOffset: coverWidgetOffset ?? Offset.zero,
            animationController: flyAnimationController,
            flyHeight: widget.flyHeight,
            isTopStart: widget.isTopStart,
            isShake: widget.isShake,
            child: widget.child,
          ),
          if (widget.coverWidget != null)
            Positioned(
              left: coverWidgetOffset?.dx,
              top: coverWidgetOffset?.dy,
              child: widget.coverWidget!,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.animationController.removeStatusListener(_handleAnimationStatus);
    super.dispose();
  }
}

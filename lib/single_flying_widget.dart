import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A widget that creates a single flying animation effect.
///
/// This widget is used internally by [FlyingWidget] to create the actual
/// flying animation effect. It handles the positioning, rotation, and
/// opacity animations of the flying widget.
class SingleFlyingWidget extends StatefulWidget {
  /// The key used to get the size of the cover widget.
  final GlobalKey coverWidgetKey;

  /// The controller for the flying animation.
  final AnimationController animationController;

  /// The offset of the cover widget.
  final Offset coverWidgetOffset;

  /// The widget that will be animated.
  final Widget child;

  /// The maximum height the widget will fly to.
  final double flyHeight;

  /// Whether the animation should start from the top.
  final bool isTopStart;

  /// Whether the widget should shake during animation.
  final bool isShake;

  const SingleFlyingWidget({
    super.key,
    required this.coverWidgetKey,
    required this.animationController,
    required this.coverWidgetOffset,
    required this.child,
    required this.flyHeight,
    required this.isTopStart,
    required this.isShake,
  });

  @override
  State<SingleFlyingWidget> createState() => _SingleFlyingWidgetState();
}

class _SingleFlyingWidgetState extends State<SingleFlyingWidget> {
  late final List<Offset> _shakePathOffsets;
  late final Animation<double> _positionAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _rotationAnimation;
  final GlobalKey _flyWidgetKey = GlobalKey();
  Offset? _startOffset;
  double? _previousRotation;

  @override
  void initState() {
    _initializeAnimations();
    _calculateStartOffset();
    super.initState();
  }

  void _initializeAnimations() {
    _shakePathOffsets = _createShakePathOffsets();
    _positionAnimation = _createPositionAnimation();
    _opacityAnimation =
        Tween<double>(begin: 1, end: 0).animate(widget.animationController);
    _rotationAnimation = Tween<double>(begin: 0, end: pi / 4).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  void _calculateStartOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coverRenderBox = widget.coverWidgetKey.currentContext
          ?.findRenderObject() as RenderBox?;
      final coverSize = coverRenderBox?.size ?? Size.zero;

      final flyRenderBox =
          _flyWidgetKey.currentContext?.findRenderObject() as RenderBox?;
      final flySize = flyRenderBox?.size ?? Size.zero;

      if (flyRenderBox != null) {
        final startXOffset = widget.coverWidgetOffset.dx +
            (coverSize.width / 2) -
            (flySize.width / 2);

        final centerCoverYOffset = widget.coverWidgetOffset.dy +
            (coverSize.height / 2) -
            (flySize.height / 2);

        final coverTopOffset = widget.coverWidgetOffset.dy - flySize.height;

        setState(() {
          _startOffset = Offset(
            startXOffset,
            widget.isTopStart ? coverTopOffset : centerCoverYOffset,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentOffset = _getInterpolatedOffset(_positionAnimation.value);
    final rotation = _calculateRotation(currentOffset);

    return Positioned(
      key: _flyWidgetKey,
      left: currentOffset.dx,
      top: currentOffset.dy,
      child: Opacity(
        opacity: _startOffset == null ? 0 : _opacityAnimation.value,
        child: Transform.rotate(
          angle: widget.isShake ? rotation : 0,
          child: widget.child,
        ),
      ),
    );
  }

  double _calculateRotation(Offset currentOffset) {
    final currentX = currentOffset.dx;
    final previousX = _getInterpolatedOffset(_positionAnimation.value - 0.1).dx;
    final isMovingRight = currentX > previousX;

    final baseRotation = _rotationAnimation.value;
    final targetRotation = isMovingRight ? baseRotation : -baseRotation;
    final currentRotation = _previousRotation ?? targetRotation;
    final smoothRotation =
        ui.lerpDouble(currentRotation, targetRotation, 0.1) ?? currentRotation;

    _previousRotation = smoothRotation;
    return smoothRotation;
  }

  Offset _getInterpolatedOffset(double animationValue) {
    if (_shakePathOffsets.isEmpty) return Offset.zero;

    animationValue = animationValue.clamp(0.0, _shakePathOffsets.length - 1.0);

    int startIndex =
        animationValue.floor().clamp(0, _shakePathOffsets.length - 1);
    int endIndex = animationValue.ceil().clamp(0, _shakePathOffsets.length - 1);
    double t = animationValue - startIndex;

    return (Offset.lerp(
              _shakePathOffsets[startIndex],
              _shakePathOffsets[endIndex],
              t,
            ) ??
            Offset.zero) +
        (_startOffset ?? Offset.zero);
  }

  List<Offset> _createShakePathOffsets() {
    final List<Offset> pathOffsets = [Offset.zero];
    for (int i = 1; i < 7; i++) {
      final xOffset = widget.isShake
          ? Random().nextInt(i * 5) - Random().nextInt(i * 5).toDouble()
          : 0.0;
      final yOffset = pathOffsets[i - 1].dy - Random().nextInt(20) - 20;
      pathOffsets.add(Offset(xOffset, yOffset));
    }

    return pathOffsets.map((offset) {
      return Offset(
        offset.dx,
        offset.dy * -(widget.flyHeight / pathOffsets.last.dy),
      );
    }).toList();
  }

  Animation<double> _createPositionAnimation() {
    return Tween<double>(begin: 0, end: _shakePathOffsets.length - 1).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }
}

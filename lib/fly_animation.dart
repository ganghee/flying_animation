import 'dart:math';

import 'package:flutter/material.dart';

class FlyAnimationWidget extends StatefulWidget {
  final AnimationController animationController;
  final Icon icon;
  final Icon flyIcon;

  const FlyAnimationWidget({
    super.key,
    required this.animationController,
    required this.icon,
    required this.flyIcon,
  });

  @override
  State<FlyAnimationWidget> createState() => _FlyAnimationWidgetState();
}

class _FlyAnimationWidgetState extends State<FlyAnimationWidget>
    with TickerProviderStateMixin {
  OverlayEntry? overlayEntry;
  late final Animation<double> opacityAnimation =
      Tween<double>(begin: 1, end: 0).animate(widget.animationController);
  final GlobalKey flyWidgetKey = GlobalKey();

  @override
  initState() {
    super.initState();
    final int? milliSecond =
        widget.animationController.duration?.inMilliseconds;
    if (milliSecond == null || milliSecond == 0) {
      widget.animationController.duration = const Duration(seconds: 1);
    }
    widget.animationController.addStatusListener((status) {
      final flyAnimationController = AnimationController(vsync: this);
      if (status.isAnimating) {
        flyAnimationController.duration = widget.animationController.duration;
        flyAnimationController.forward();
        createFlyIconOverlay(flyAnimationController: flyAnimationController);
      } else if (status.isCompleted) {
        removeFlyIconOverlay();
        if (context.mounted) {
          flyAnimationController.reset();
        }
      }
    });
  }

  createFlyIconOverlay({required AnimationController flyAnimationController}) {
    overlayEntry = OverlayEntry(
      builder: (context) {
        final offset =
            (flyWidgetKey.currentContext?.findRenderObject() as RenderBox)
                .localToGlobal(Offset.zero);
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _FlyWidget(
              iconOffset: offset,
              animationController: flyAnimationController,
              sizeDiff:
                  (((widget.flyIcon.size ?? 0) - (widget.icon.size ?? 0)) / 2)
                      .toInt(),
              flyIcon: widget.flyIcon,
            ),
            widget.icon,
          ],
        );
      },
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  removeFlyIconOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  @override
  void dispose() {
    removeFlyIconOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: flyWidgetKey, child: widget.icon);
  }
}

class _FlyWidget extends StatefulWidget {
  final AnimationController animationController;
  final Offset iconOffset;
  final int sizeDiff;
  final Icon flyIcon;

  const _FlyWidget({
    required this.animationController,
    required this.iconOffset,
    required this.sizeDiff,
    required this.flyIcon,
  });

  @override
  State<_FlyWidget> createState() => _FlyWidgetState();
}

class _FlyWidgetState extends State<_FlyWidget> {
  late final List<Offset> _pathOffsets;
  late final Animation<double> positionAnimation;
  late final Animation<double> opacityAnimation;

  @override
  void initState() {
    _pathOffsets = [
      Offset(
        widget.iconOffset.dx + Random().nextInt(20) - 10,
        widget.iconOffset.dy + 0,
      ),
      Offset(
        widget.iconOffset.dx + Random().nextInt(20) - 10,
        widget.iconOffset.dy - 10,
      ),
      Offset(
        widget.iconOffset.dx + Random().nextInt(20) - 10,
        widget.iconOffset.dy - 20,
      ),
      Offset(
        widget.iconOffset.dx + Random().nextInt(20) - 10,
        widget.iconOffset.dy - 30,
      ),
      Offset(
        widget.iconOffset.dx + Random().nextInt(20) - 10,
        widget.iconOffset.dy - 40,
      ),
      Offset(
        widget.iconOffset.dx + Random().nextInt(20) - 10,
        widget.iconOffset.dy - 50,
      ),
      Offset(
        widget.iconOffset.dx + Random().nextInt(20) - 10,
        widget.iconOffset.dy - 60,
      ),
    ];
    positionAnimation =
        Tween<double>(begin: 0, end: _pathOffsets.length - 1).animate(
      CurvedAnimation(
          parent: widget.animationController, curve: Curves.easeInOut),
    )..addListener(() {
            if (mounted) {
              setState(() {});
            }
          });
    opacityAnimation =
        Tween<double>(begin: 1, end: 0).animate(widget.animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Offset currentOffset =
        _getInterpolatedOffset(positionAnimation.value);

    return Positioned(
      top: currentOffset.dy - widget.sizeDiff,
      left: currentOffset.dx - widget.sizeDiff,
      child: Opacity(
        opacity: opacityAnimation.value,
        child: widget.flyIcon,
      ),
    );
  }

  Offset _getInterpolatedOffset(double animationValue) {
    int startIndex = animationValue.floor();
    int endIndex = (animationValue.ceil()).clamp(0, _pathOffsets.length - 1);
    double t = animationValue - startIndex;

    return Offset.lerp(_pathOffsets[startIndex], _pathOffsets[endIndex], t)!;
  }
}

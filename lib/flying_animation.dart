import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FlyingAnimationWidget extends StatefulWidget {
  final AnimationController animationController;
  final Icon icon;
  final Icon flyIcon;

  const FlyingAnimationWidget({
    super.key,
    this.icon = const Icon(
      Icons.add,
      color: Colors.transparent,
      size: 20,
    ),
    required this.animationController,
    required this.flyIcon,
  });

  @override
  State<FlyingAnimationWidget> createState() => _FlyingAnimationWidgetState();
}

class _FlyingAnimationWidgetState extends State<FlyingAnimationWidget>
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
        final sizeDiff =
            (((widget.flyIcon.size ?? 0) - (widget.icon.size ?? 24)) / 2)
                .toInt();
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _FlyWidget(
              iconOffset: offset,
              animationController: flyAnimationController,
              sizeDiff: sizeDiff,
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
  late final Animation<double> _positionAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    _pathOffsets = setPathOffset();
    _positionAnimation = setPositionAnimation();
    _opacityAnimation =
        Tween<double>(begin: 1, end: 0).animate(widget.animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Offset currentOffset =
        _getInterpolatedOffset(_positionAnimation.value);

    return Positioned(
      left: currentOffset.dx -
          widget.sizeDiff -
          _pathOffsets[0].dx +
          widget.iconOffset.dx,
      top: currentOffset.dy,
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: widget.flyIcon,
      ),
    );
  }

  Offset _getInterpolatedOffset(double animationValue) {
    int startIndex = animationValue.floor();
    int endIndex = (animationValue.ceil()).clamp(1, _pathOffsets.length - 1);
    double t = animationValue - startIndex;

    return Offset.lerp(_pathOffsets[startIndex], _pathOffsets[endIndex], t)!;
  }

  List<Offset> setPathOffset() {
    final List<double> randomYOffsets = [0];

    for (int i = 1; i < 7; i++) {
      randomYOffsets.add(randomYOffsets[i - 1] - Random().nextInt(20) - 20);
    }
    return randomYOffsets.mapIndexed((index, yOffset) {
      final xOffset =
          Random().nextInt((index + 1) * 5) - Random().nextInt((index + 1) * 5);
      final Offset startOffset = Offset(
        widget.iconOffset.dx,
        widget.iconOffset.dy - widget.sizeDiff,
      );
      return Offset(
        startOffset.dx + xOffset,
        startOffset.dy + yOffset,
      );
    }).toList();
  }

  Animation<double> setPositionAnimation() {
    return Tween<double>(begin: 0, end: _pathOffsets.length - 1).animate(
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

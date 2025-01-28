import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FlyingImageWidget extends StatefulWidget {
  final AnimationController animationController;
  final String? image;
  final double imageWidth;
  final double imageHeight;
  final String flyImage;
  final double flyImageWidth;
  final double flyImageHeight;

  const FlyingImageWidget({
    super.key,
    this.image,
    this.imageWidth = 24,
    this.imageHeight = 24,
    this.flyImageWidth = 24,
    this.flyImageHeight = 24,
    required this.animationController,
    required this.flyImage,
  });

  @override
  State<FlyingImageWidget> createState() => _FlyingImageWidgetState();
}

class _FlyingImageWidgetState extends State<FlyingImageWidget>
    with TickerProviderStateMixin {
  OverlayEntry? overlayEntry;
  late final Animation<double> opacityAnimation =
      Tween<double>(begin: 1, end: 0).animate(widget.animationController);
  final GlobalKey flyWidgetKey = GlobalKey();

  @override
  void initState() {
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
    super.initState();
  }

  createFlyIconOverlay({required AnimationController flyAnimationController}) {
    overlayEntry = OverlayEntry(
      builder: (context) {
        final offset =
            (flyWidgetKey.currentContext?.findRenderObject() as RenderBox)
                .localToGlobal(Offset.zero);
        final sizeDiff =
            (((widget.flyImageWidth) - (widget.imageWidth)) / 2).toInt();
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _FlyWidget(
              iconOffset: offset,
              animationController: flyAnimationController,
              sizeDiff: sizeDiff,
              flyImage: widget.flyImage,
            ),
            Image.network(
              widget.image!,
              width: widget.imageWidth,
              height: widget.imageHeight,
            ),
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
  Widget build(BuildContext context) {
    return Container(
      key: flyWidgetKey,
      child: Image.network(
        widget.image!,
        width: widget.imageWidth,
        height: widget.imageHeight,
      ),
    );
  }
}

class _FlyWidget extends StatefulWidget {
  final AnimationController animationController;
  final Offset iconOffset;
  final int sizeDiff;
  final String flyImage;

  const _FlyWidget({
    required this.animationController,
    required this.iconOffset,
    required this.sizeDiff,
    required this.flyImage,
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
        child: Image.network(
          widget.flyImage,
          width: 42,
          height: 42,
        ),
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

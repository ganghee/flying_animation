import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FlyingImageWidget extends StatefulWidget {
  final AnimationController animationController;
  final Widget? image;
  final Widget flyImage;

  const FlyingImageWidget({
    super.key,
    this.image,
    required this.animationController,
    required this.flyImage,
  });

  @override
  State<FlyingImageWidget> createState() => _FlyingImageWidgetState();
}

class _FlyingImageWidgetState extends State<FlyingImageWidget>
    with TickerProviderStateMixin {
  late final Animation<double> opacityAnimation =
      Tween<double>(begin: 1, end: 0).animate(widget.animationController);
  final GlobalKey imageWidgetKey = GlobalKey();
  final GlobalKey flyImageWidgetKey = GlobalKey();

  @override
  initState() {
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
        final OverlayEntry overlayEntry = createFlyImageOverlay(
          flyAnimationController: flyAnimationController,
        );
        Overlay.of(context).insert(overlayEntry);
        Future.delayed(Duration(milliseconds: milliSecond ?? 1000), () {
          overlayEntry.remove();
          overlayEntry.dispose();
          flyAnimationController.dispose();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.image == null
            ? const SizedBox()
            : Builder(
                key: imageWidgetKey,
                builder: (BuildContext context) {
                  return widget.image!;
                },
              ),
        Opacity(
          key: flyImageWidgetKey,
          opacity: 0,
          child: widget.flyImage,
        ),
      ],
    );
  }

  OverlayEntry createFlyImageOverlay({
    required AnimationController flyAnimationController,
  }) {
    final imageRenderBox =
        imageWidgetKey.currentContext?.findRenderObject() as RenderBox?;
    final imageOffset = imageRenderBox?.localToGlobal(Offset.zero);
    final flyImageRenderBox =
        flyImageWidgetKey.currentContext?.findRenderObject() as RenderBox;
    final flyImageOffset = flyImageRenderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _FlyWidget(
              flyOffset: flyImageOffset,
              animationController: flyAnimationController,
              flyImage: widget.flyImage,
            ),
            widget.image == null
                ? const SizedBox()
                : Positioned(
                    left: imageOffset?.dx,
                    top: imageOffset?.dy,
                    child: widget.image!,
                  ),
          ],
        );
      },
    );
  }
}

class _FlyWidget extends StatefulWidget {
  final AnimationController animationController;
  final Offset flyOffset;
  final Widget flyImage;

  const _FlyWidget({
    required this.animationController,
    required this.flyOffset,
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
      left: currentOffset.dx - _pathOffsets[0].dx + widget.flyOffset.dx,
      top: currentOffset.dy,
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: widget.flyImage,
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
        widget.flyOffset.dx,
        widget.flyOffset.dy,
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

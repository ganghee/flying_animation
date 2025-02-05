import 'dart:math';

import 'package:flutter/material.dart';

part 'flying_widget.dart';

class FlyingImageWidget extends StatefulWidget {
  final Widget? image;
  final double? flyHeight;
  final AnimationController animationController;
  final Widget flyImage;

  const FlyingImageWidget({
    super.key,
    this.image,
    this.flyHeight = 100,
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
    return widget.image == null
        ? const SizedBox()
        : Builder(
            key: imageWidgetKey,
            builder: (BuildContext context) {
              return widget.image!;
            },
          );
  }

  OverlayEntry createFlyImageOverlay({
    required AnimationController flyAnimationController,
  }) {
    final imageRenderBox =
        imageWidgetKey.currentContext?.findRenderObject() as RenderBox?;
    final imageOffset = imageRenderBox?.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _FlyWidget(
              imageWidgetKey: imageWidgetKey,
              imageOffset: imageOffset ?? Offset.zero,
              animationController: flyAnimationController,
              flyImage: widget.flyImage,
              flyHeight: widget.flyHeight ?? 200,
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

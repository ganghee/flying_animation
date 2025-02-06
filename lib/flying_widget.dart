import 'dart:math';

import 'package:flutter/material.dart';

part 'single_flying_widget.dart';

class FlyingWidget extends StatefulWidget {
  final Widget? coverWidget;
  final double flyHeight;
  final AnimationController animationController;
  final Widget child;

  const FlyingWidget({
    super.key,
    this.coverWidget,
    this.flyHeight = 100,
    required this.animationController,
    required this.child,
  });

  @override
  State<FlyingWidget> createState() => _FlyingWidgetState();
}

class _FlyingWidgetState extends State<FlyingWidget>
    with TickerProviderStateMixin {
  late final Animation<double> opacityAnimation =
      Tween<double>(begin: 1, end: 0).animate(widget.animationController);
  final GlobalKey coverWidgetKey = GlobalKey();

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
        final OverlayEntry overlayEntry = createFlyOverlay(
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
    return widget.coverWidget == null
        ? const SizedBox()
        : Builder(
            key: coverWidgetKey,
            builder: (BuildContext context) {
              return widget.coverWidget!;
            },
          );
  }

  OverlayEntry createFlyOverlay({
    required AnimationController flyAnimationController,
  }) {
    final coverRenderBox =
        coverWidgetKey.currentContext?.findRenderObject() as RenderBox?;
    final coverWidgetOffset = coverRenderBox?.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _SingleFlyWidget(
              coverWidgetKey: coverWidgetKey,
              coverWidgetOffset: coverWidgetOffset ?? Offset.zero,
              animationController: flyAnimationController,
              flyHeight: widget.flyHeight,
              child: widget.child,
            ),
            widget.coverWidget == null
                ? const SizedBox()
                : Positioned(
                    left: coverWidgetOffset?.dx,
                    top: coverWidgetOffset?.dy,
                    child: widget.coverWidget!,
                  ),
          ],
        );
      },
    );
  }
}

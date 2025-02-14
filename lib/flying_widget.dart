import 'dart:math';

import 'package:flutter/material.dart';

part 'single_flying_widget.dart';

/// This widget is used to create a flying animation to top.
/// [coverWidget] is the widget that covered by the flying widget.
/// And the coverWidget not move.
/// [flyHeight] is the height of max flying distance until disappear.
/// [isTopStart] is the flag to determine the flying widget start from top or center.
/// [isShake] is the flag to determine the flying widget shake or not.
/// [animationController] is the controller to control the flying animation.
/// [child] is the widget that will be flying.
class FlyingWidget extends StatefulWidget {
  final Widget? coverWidget;
  final bool isTopStart;
  final double flyHeight;
  final bool isShake;
  final AnimationController animationController;
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
  late final Animation<double> opacityAnimation =
      Tween<double>(begin: 1, end: 0).animate(widget.animationController);

  /// [coverWidgetKey] is the key to get size.
  final GlobalKey coverWidgetKey = GlobalKey();

  @override
  initState() {
    /// If the millisecond is null or 0, set the duration to 1 second.
    /// the duration is used to control the animation speed.
    final int? milliSecond =
        widget.animationController.duration?.inMilliseconds;
    if (milliSecond == null || milliSecond == 0) {
      widget.animationController.duration = const Duration(seconds: 1);
    }

    /// Add status listener to the animation controller.
    /// If the animation is animating, create the overlay entry.
    /// The overlay entry is used to show the flying widget.
    widget.animationController.addStatusListener((status) {
      final flyAnimationController = AnimationController(vsync: this);
      if (status.isAnimating) {
        flyAnimationController.duration = widget.animationController.duration;
        flyAnimationController.forward();
        final OverlayEntry overlayEntry = createFlyOverlay(
          flyAnimationController: flyAnimationController,
        );
        Overlay.of(context).insert(overlayEntry);

        /// If the millisecond is null or 0, set the duration to 1 second.
        /// And then remove the overlay entry after the duration.
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

  /// Create the overlay entry to show the flying widget.
  /// [flyAnimationController] is the controller to control the flying animation.
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
            /// Create the flying widget.
            _SingleFlyWidget(
              coverWidgetKey: coverWidgetKey,
              coverWidgetOffset: coverWidgetOffset ?? Offset.zero,
              animationController: flyAnimationController,
              flyHeight: widget.flyHeight,
              isTopStart: widget.isTopStart,
              isShake: widget.isShake,
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

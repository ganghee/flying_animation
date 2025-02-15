part of 'flying_widget.dart';

/// This widget is used to create a flying animation to top.
/// [coverWidgetKey] is the key to get size.
/// [coverWidgetOffset] is the offset of the cover widget.
/// [flyHeight] is the height of max flying distance until disappear.
/// [isTopStart] is the flag to determine the flying widget start from top or center.
/// [isShake] is the flag to determine the flying widget shake or not.
class _SingleFlyWidget extends StatefulWidget {
  final GlobalKey coverWidgetKey;
  final AnimationController animationController;
  final Offset coverWidgetOffset;
  final Widget child;
  final double flyHeight;
  final bool isTopStart;
  final bool isShake;

  const _SingleFlyWidget({
    required this.coverWidgetKey,
    required this.animationController,
    required this.coverWidgetOffset,
    required this.child,
    required this.flyHeight,
    required this.isTopStart,
    required this.isShake,
  });

  @override
  State<_SingleFlyWidget> createState() => _SingleFlyWidgetState();
}

class _SingleFlyWidgetState extends State<_SingleFlyWidget> {
  late final List<Offset> _shakePathOffsets;
  late final Animation<double> _positionAnimation;
  late final Animation<double> _opacityAnimation;
  final GlobalKey _flyWidgetKey = GlobalKey();
  Offset? _startOffset;

  @override
  void initState() {
    _shakePathOffsets = setShakePathOffset();
    _positionAnimation = setPositionAnimation();
    _opacityAnimation =
        Tween<double>(begin: 1, end: 0).animate(widget.animationController);
    super.initState();

    /// Get the start offset of the flying widget.
    /// The start offset is calculated based on the cover widget position and size.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? coverRenderBox = widget.coverWidgetKey.currentContext
          ?.findRenderObject() as RenderBox?;
      final coverRenderBoxSize = coverRenderBox?.size ?? Size.zero;
      final RenderBox? flyRenderBox =
          _flyWidgetKey.currentContext?.findRenderObject() as RenderBox?;
      final flyRenderBoxSize = flyRenderBox?.size ?? Size.zero;
      final startXOffset = widget.coverWidgetOffset.dx +
          (coverRenderBoxSize.width / 2) -
          (flyRenderBoxSize.width) / 2;
      final centerCoverYOffset = widget.coverWidgetOffset.dy +
          (coverRenderBoxSize.height / 2) -
          (flyRenderBoxSize.height) / 2;
      final coverTopOffset =
          widget.coverWidgetOffset.dy - flyRenderBoxSize.height;
      if (flyRenderBox != null) {
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
    final Offset currentOffset =
        _getInterpolatedOffset(_positionAnimation.value);

    /// The flying widget is positioned based on the current offset.
    return Positioned(
      key: _flyWidgetKey,
      left: currentOffset.dx,
      top: currentOffset.dy,
      child: Opacity(
        opacity: _startOffset == null ? 0 : _opacityAnimation.value,
        child: widget.child,
      ),
    );
  }

  /// Get the interpolated offset based on the animation value.
  /// The interpolated offset is calculated based on the current animation value.
  /// [animationValue] is the current value of the position animation.
  /// Return the interpolated offset.
  Offset _getInterpolatedOffset(double animationValue) {
    int startIndex = animationValue.floor();
    int endIndex =
        (animationValue.ceil()).clamp(1, _shakePathOffsets.length - 1);
    double t = animationValue - startIndex;

    return (Offset.lerp(
              _shakePathOffsets[startIndex],
              _shakePathOffsets[endIndex],
              t,
            ) ??
            Offset.zero) +
        (_startOffset ?? Offset.zero);
  }

  /// Set the shake path offset.
  List<Offset> setShakePathOffset() {
    final List<Offset> pathOffsets = [Offset.zero];
    for (int i = 1; i < 7; i++) {
      final xOffset = widget.isShake
          ? Random().nextInt(i * 5) - Random().nextInt(i * 5).toDouble()
          : 0.0;
      final yOffset = pathOffsets[i - 1].dy - Random().nextInt(20) - 20;
      pathOffsets.add(
        Offset(xOffset, yOffset),
      );
    }
    return pathOffsets.map((offset) {
      return Offset(
        offset.dx,
        offset.dy * -(widget.flyHeight / pathOffsets.last.dy),
      );
    }).toList();
  }

  /// According to [_shakePathOffsets], set the position animation.
  Animation<double> setPositionAnimation() {
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

part of 'flying_image.dart';

class _FlyWidget extends StatefulWidget {
  final GlobalKey imageWidgetKey;
  final AnimationController animationController;
  final Offset imageOffset;
  final Widget flyImage;
  final double flyHeight;

  const _FlyWidget({
    required this.imageWidgetKey,
    required this.animationController,
    required this.imageOffset,
    required this.flyImage,
    required this.flyHeight,
  });

  @override
  State<_FlyWidget> createState() => _FlyWidgetState();
}

class _FlyWidgetState extends State<_FlyWidget> {
  late final List<Offset> _pathOffsets;
  late final Animation<double> _positionAnimation;
  late final Animation<double> _opacityAnimation;
  final GlobalKey _overlayKey = GlobalKey();
  Offset? _flyWidgetOffset;

  @override
  void initState() {
    _pathOffsets = setPathOffset();
    _positionAnimation = setPositionAnimation();
    _opacityAnimation =
        Tween<double>(begin: 1, end: 0).animate(widget.animationController);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? imageRenderBox = widget.imageWidgetKey.currentContext
          ?.findRenderObject() as RenderBox?;
      final imageRenderBoxSize = imageRenderBox?.size;
      final RenderBox? flyImageRenderBox =
          _overlayKey.currentContext?.findRenderObject() as RenderBox?;
      final flyRenderBoxSize = flyImageRenderBox?.size;
      if (flyImageRenderBox != null) {
        setState(() {
          _flyWidgetOffset = Offset(
            widget.imageOffset.dx +
                ((imageRenderBoxSize?.width ?? 0) / 2) -
                (flyRenderBoxSize?.width ?? 0) / 2,
            widget.imageOffset.dy +
                ((imageRenderBoxSize?.height ?? 0) / 2) -
                (flyRenderBoxSize?.height ?? 0) / 2,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Offset currentOffset =
        _getInterpolatedOffset(_positionAnimation.value);

    return Positioned(
      key: _overlayKey,
      left: currentOffset.dx - _pathOffsets[0].dx + (_flyWidgetOffset?.dx ?? 0),
      top: currentOffset.dy + (_flyWidgetOffset?.dy ?? 0),
      child: Opacity(
        opacity: _flyWidgetOffset == null ? 0 : _opacityAnimation.value,
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
    final Offset startOffset = Offset.zero;
    final List<Offset> pathOffsets = [Offset.zero];
    for (int i = 1; i < 7; i++) {
      final xOffset =
          Random().nextInt(i * 5) - Random().nextInt(i * 5).toDouble();
      final yOffset = pathOffsets[i - 1].dy - Random().nextInt(20) - 20;
      pathOffsets.add(
        Offset(xOffset, yOffset),
      );
    }
    return pathOffsets.map((offset) {
      return startOffset +
          Offset(
            offset.dx,
            offset.dy * -(widget.flyHeight / pathOffsets.last.dy),
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

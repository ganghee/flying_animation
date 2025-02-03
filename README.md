## Features

<img src="https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExNnl0N24xM3Y1bmdnZTRuamxtdzdoM3BhZnM4dW85aWxqbnlqczJwZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/rmX2RTElmpGHIQ2d6L/giphy.gif" alt="Alt text">

This package provides a widget that can fly an image from one position to another.  
Not only image, but also you can fly any widget.  
You can control flying height.  
Also you can control speed using duration parameter of AnimationController.

## Usage

```dart
FlyingImageWidget(
  animationController: animationController,
  flyImage: SvgPicture.asset('assets/ic_heart.svg'),
  image: SvgPicture.asset('assets/ic_heart.svg'),
  flyHeight: 100,
)
```

## Features

<img src="https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExbWNreWJjajN4cm1ndm94bmowZWYwYmg3M3o4MzkwajJjbzV5M3o0NSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/IV3nhXrwDcuT5XKCdP/giphy.gif" alt="Alt text">

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

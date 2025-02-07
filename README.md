## Features

<img src="https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExbWNreWJjajN4cm1ndm94bmowZWYwYmg3M3o4MzkwajJjbzV5M3o0NSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/IV3nhXrwDcuT5XKCdP/giphy.gif" alt="Alt text">
<img src="https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExZjlhYzM2anp3a3U0NWFoMXZhc2J2bXY2ZGxuYnZtZ3dwd3l6Mjl1OCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/A73WQLCnyCT81pvf83/giphy.gif" alt="Alt text">

This package provides a widget that can fly an image from one position to another.  
Not only image, but also you can fly any widget.  
You can control flying height.  
Also you can control speed using duration parameter of AnimationController.

## Usage

```dart
FlyingImageWidget(
  animationController: animationController,
  image: Icon(Icons.favorite, color: Colors.red),
  flyImage: Icon(Icons.favorite, color: Colors.red),
)
```

## Parameters

| name                | Type                | required | Default Value | Usage                                                                                                                                                                                                                                             |
|---------------------|---------------------|----------|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| coverWidget         | Widget              | false    | null          | This widget is on top widget. no fly.                                                                                                                                                                                                             |
| flyHeight           | double              | false    | 100           | Flying widget can fly up to a specified height.                                                                                                                                                                                                   |
| isTopStart          | bool                | false    | false         | If it is true, fly widget start animation on top of coverWidget.                                                                                                                                                                                  |
| isShake                    | bool                | false    | false         | If it is false, the fly widget does not shake during animating.                                                                                                                                                                                   |
| animationController | AnimationController | true     | null          | You can controll animation using AnimationController class. <br/> The animation speed is set by duration parameter. <br/> If you start animation, ```_animationController.reset() _animationController.forward()``` must be implemented in order. |
| child               | Widget              | true     | null          | This widget randomly swings and flies upward.                                                                                                                                                                                                     |

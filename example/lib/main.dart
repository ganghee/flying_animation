import 'package:flutter/material.dart';
import 'package:flying_animation/flying_icon.dart';
import 'package:flying_animation/flying_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlyingIconWidget(
              animationController: animationController,
              icon: Icon(
                color: Colors.blue,
                size: 42,
                Icons.accessibility,
              ),
              flyIcon: Icon(
                color: Colors.red,
                size: 52,
                Icons.accessibility,
              ),
            ),
            FlyingImageWidget(
              animationController: animationController,
              image:
                  'https://i.namu.wiki/i/QmrRDGa5ZceyrVAGpE0X_G__5eTzxDbYED_MmNoUSkXOUcs7Ox2nGGFGzHiSWwA9AI2E8vTHb7TjF0msFfaatrt4Q2qZi-aBHk_Xg3jyQmr8ZfwVsy-DL5y3DWifvqu2bWa3ceS5wtj4MmFB1Ipalw.webp',
              flyImage:
                  'https://i.namu.wiki/i/XouKYtozQBPTdq7vDlY7ihtKNT9PNpTtd2w60Silgg29iVoVf8_Q6KEnQv7rOi0tg61c_kFAnO2A6LK3FlsUmLAw91WFSOEz6YBlEYHmpMg-IkfIEh1B4nIqgBka50G7dESHJrk2edqYtlrI8RhVPA.webp',
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!context.mounted) return;
          animationController.reset();
          animationController.forward();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

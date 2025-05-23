import 'package:flutter/material.dart';
import 'package:flying_animation/flying_widget.dart';

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
            FlyingWidget(
              coverWidget: Icon(Icons.favorite, color: Colors.red),
              animationController: animationController,
              child: Icon(Icons.favorite, color: Colors.red),
            ),
            const SizedBox(height: 20),

            /// Click the button to trigger the flying widget animation.
            /// reset and forword method is used to reset the animation and start the animation.
            ElevatedButton(
              onPressed: () {
                if (!context.mounted) return;
                animationController.reset();
                animationController.forward();
              },
              child: const Text('Click me'),
            ),
          ],
        ),
      ),
    );
  }
}

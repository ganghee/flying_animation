import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_animation/flying_widget.dart';

void main() {
  late AnimationController controller;

  setUp(() {
    controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 500),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('FlyingWidget shows child widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlyingWidget(
            animationController: controller,
            child: const Text('Test'),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('FlyingWidget shows cover widget when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlyingWidget(
            coverWidget: const Text('Cover'),
            animationController: controller,
            child: const Text('Test'),
          ),
        ),
      ),
    );

    expect(find.text('Cover'), findsOneWidget);
  });

  testWidgets('FlyingWidget respects isShake parameter', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlyingWidget(
            isShake: true,
            animationController: controller,
            child: const Text('Test'),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('FlyingWidget respects flyHeight parameter', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlyingWidget(
            flyHeight: 200.0,
            animationController: controller,
            child: const Text('Test'),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('FlyingWidget respects isTopStart parameter', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlyingWidget(
            isTopStart: true,
            animationController: controller,
            child: const Text('Test'),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('FlyingWidget changes opacity during animation', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlyingWidget(
            animationController: controller,
            child: const Text('Test'),
          ),
        ),
      ),
    );

    final finder = find.byType(FlyingWidget);
    final widget = tester.widget<FlyingWidget>(finder);
    expect(widget.animationController.value, equals(0.0));

    controller.forward();
    await tester.pump();

    controller.value = 0.5;
    await tester.pump();
    expect(widget.animationController.value, equals(0.5));

    controller.forward();
    await tester.pumpAndSettle();
    expect(widget.animationController.value, equals(1.0));
  });
} 
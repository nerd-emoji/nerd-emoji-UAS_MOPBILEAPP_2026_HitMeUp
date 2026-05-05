import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hitmeup/screens/mainApp/discover.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Discover Integration Test', () {

    testWidgets('Discover screen loads',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: SwipeCardScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('Buttons exist and can be tapped',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: SwipeCardScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final likeButton = find.byIcon(Icons.thumb_up_alt_rounded);
      final dislikeButton = find.byIcon(Icons.thumb_down_alt_rounded);

      expect(likeButton, findsOneWidget);
      expect(dislikeButton, findsOneWidget);

      await tester.tap(likeButton);
      await tester.pump();

      await tester.tap(dislikeButton);
      await tester.pump();

      expect(find.byType(SwipeCardScreen), findsOneWidget);
    });

    testWidgets('Simulate swipe gesture',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: SwipeCardScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(200, 400));
      await gesture.moveBy(const Offset(300, 0)); // swipe kanan
      await gesture.up();

      await tester.pumpAndSettle();

      expect(find.byType(SwipeCardScreen), findsOneWidget);
    });

  });
}
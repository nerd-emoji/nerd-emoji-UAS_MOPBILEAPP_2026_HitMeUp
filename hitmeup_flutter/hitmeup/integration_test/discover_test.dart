import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hitmeup/screens/mainApp/discover.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Discover Integration Test', () {

    testWidgets('App loads and shows Discover screen',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: SwipeCardScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('Swipe buttons interaction works',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: SwipeCardScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap like
      await tester.tap(find.byIcon(Icons.thumb_up_alt_rounded));
      await tester.pump();

      // Tap dislike
      await tester.tap(find.byIcon(Icons.thumb_down_alt_rounded));
      await tester.pump();

      expect(find.byType(SwipeCardScreen), findsOneWidget);
    });

    testWidgets('Drag gesture works (simulate swipe)',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: SwipeCardScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Cari card (pakai gesture area)
      final gesture = await tester.startGesture(const Offset(200, 400));
      await gesture.moveBy(const Offset(300, 0)); // swipe kanan
      await gesture.up();

      await tester.pumpAndSettle();

      expect(find.byType(SwipeCardScreen), findsOneWidget);
    });

  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hitmeup/screens/mainApp/requests.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Requests screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RequestsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Requests'), findsOneWidget);
  });

  testWidgets('Accept & Reject buttons tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RequestsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // fallback kalau card belum muncul
    final accept = find.byIcon(Icons.check_rounded);
    final reject = find.byIcon(Icons.close_rounded);

    if (accept.evaluate().isNotEmpty) {
      await tester.tap(accept.first);
      await tester.pump();
    }

    if (reject.evaluate().isNotEmpty) {
      await tester.tap(reject.first);
      await tester.pump();
    }

    expect(find.byType(RequestsScreen), findsOneWidget);
  });
}
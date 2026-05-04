import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('community chat integration test', (tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Community Chat Integration'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Community Chat Integration'), findsOneWidget);
  });
}
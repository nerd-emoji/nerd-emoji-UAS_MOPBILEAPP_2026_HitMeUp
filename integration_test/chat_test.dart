import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hitmeup/screens/mainApp/chat.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chat screen loads', (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    await tester.pump();

    expect(find.byType(ChatScreen), findsOneWidget);
  });
}
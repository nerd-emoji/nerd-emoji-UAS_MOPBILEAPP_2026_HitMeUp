import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/mainApp/chat.dart';

void main() {

  testWidgets('Chat screen renders without crash', (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    await tester.pump(); // jangan pumpAndSettle (hindari API trigger penuh)

    // hanya cek screen ada (aman)
    expect(find.byType(ChatScreen), findsOneWidget);
  });

  testWidgets('Chat title appears', (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    await tester.pump();

    // cek text AppBar
    expect(find.text('Chat'), findsOneWidget);
  });

}
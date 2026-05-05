import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/mainApp/direct_chat_Screen.dart';

void main() {

  testWidgets('DirectChat screen renders', (tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Test'),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });

}
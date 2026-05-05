import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('community chat widget test', (tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Community Chat Screen'),
        ),
      ),
    );

    expect(find.text('Community Chat Screen'), findsOneWidget);
  });

}
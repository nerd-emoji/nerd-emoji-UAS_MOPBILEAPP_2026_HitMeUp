import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/mainApp/requests.dart';

void main() {
  testWidgets('Requests screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RequestsScreen(),
      ),
    );

    // cek AppBar title
    expect(find.text('Requests'), findsOneWidget);
  });

  testWidgets('Loading indicator appears', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RequestsScreen(),
      ),
    );

    // karena initState load API
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Bottom nav exists', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RequestsScreen(),
      ),
    );

    expect(find.byType(BottomNavigationBar), findsNothing); 
    // karena custom nav, kita cek icon fallback
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:hitmeup/screens/signup/step1_intro_screen.dart';
import 'package:hitmeup/screens/signup/step2_birthday_screen.dart';

class _TestObserver extends NavigatorObserver {
  final void Function(Route, Route?) onPushed;
  _TestObserver(this.onPushed);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    onPushed(route, previousRoute);
  }
}

void main() {
  testWidgets('shows validation errors and handles existing email', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Step1IntroScreen(
          testCheckEmailPost: (uri, {headers, body}) async {
            return http.Response('{"exists": true}', 200);
          },
        ),
      ),
    );

    // Tap continue with empty fields
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.text('Please fill name, email, and password.'), findsOneWidget);

    // Enter name and invalid email
    await tester.enterText(find.byType(TextField).at(0), 'Bob');
    await tester.enterText(find.byType(TextField).at(1), 'invalid-email');
    await tester.enterText(find.byType(TextField).at(2), 'Short1');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);

    // Valid email but invalid password
    await tester.enterText(find.byType(TextField).at(1), 'bob@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'short');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Password must be at least'), findsOneWidget);

    // Valid password but backend says exists
    await tester.enterText(find.byType(TextField).at(2), 'LongPassword1A');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('already registered'), findsOneWidget);
  });

  testWidgets('navigates to Step3 when email not exists', (tester) async {
    bool navigated = false;
    String? navName;

    await tester.pumpWidget(
      MaterialApp(
        home: Step1IntroScreen(
          testCheckEmailPost: (uri, {headers, body}) async {
            return http.Response('{"exists": false}', 200);
          },
          testOnNavigate: (name, email, password) {
            navigated = true;
            navName = name;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Carol');
    await tester.enterText(find.byType(TextField).at(1), 'carol@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'ValidPass1A');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(navigated, isTrue);
    expect(navName, 'Carol');
  });
}

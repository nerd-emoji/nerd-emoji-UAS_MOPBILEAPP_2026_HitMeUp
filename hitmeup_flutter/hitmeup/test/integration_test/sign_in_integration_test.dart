import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hitmeup/screens/auth/sign_in_screen.dart';
import 'package:hitmeup/screens/mainApp/discover.dart';
import 'package:hitmeup/screens/signup/step1_intro_screen.dart';
import 'package:hitmeup/services/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<http.Response> _loginResponse(int statusCode, String body) async {
  return http.Response(body, statusCode, headers: {'content-type': 'application/json'});
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? replacedRoute;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacedRoute = newRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

Finder _googleIconImageFinder() {
  return find.byWidgetPredicate((widget) {
    return widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == 'assets/google_icon.png';
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.instance.clear();
  });

  testWidgets('Sign in loads', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Login success navigates to Discover', (tester) async {
    final observer = _RecordingNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        testLoginPost: (uri, {headers, body}) => _loginResponse(200, '{"id":1,"name":"Tester"}'),
      ),
      navigatorObservers: [observer],
    ));

    await tester.enterText(find.byType(TextField).at(0), 'tester@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();

    expect(find.byType(SwipeCardScreen), findsOneWidget);
    expect(observer.replacedRoute, isNotNull);
  });

  testWidgets('Google sign-up required navigates to step 1', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        testGoogleSignIn: () async => {
          'status': 'signup_required',
          'name': 'New User',
          'email': 'new@example.com',
        },
      ),
    ));

    await tester.ensureVisible(_googleIconImageFinder());
    await tester.tap(_googleIconImageFinder());
    await tester.pumpAndSettle();

    expect(find.byType(Step1IntroScreen), findsOneWidget);
  });

  testWidgets('Google linked navigates to Discover', (tester) async {
    final completer = Completer<Map<String, dynamic>?>();

    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        testGoogleSignIn: () => completer.future,
      ),
    ));

    await tester.ensureVisible(_googleIconImageFinder());
    await tester.tap(_googleIconImageFinder());
    await tester.pump();
    completer.complete({
      'status': 'linked',
      'user': {'id': 9, 'name': 'Google User'},
    });
    await tester.pumpAndSettle();

    expect(find.byType(SwipeCardScreen), findsOneWidget);
  });
}

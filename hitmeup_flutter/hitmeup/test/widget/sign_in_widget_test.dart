import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/auth/sign_in_screen.dart';
import 'package:hitmeup/screens/mainApp/discover.dart';
import 'package:hitmeup/screens/signup/step1_intro_screen.dart';
import 'package:hitmeup/services/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class _TestNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? pushedRoute;
  Route<dynamic>? replacedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoute = route;
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacedRoute = newRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

Future<http.Response> _loginResponse(int statusCode, String body) async {
  return http.Response(body, statusCode, headers: {'content-type': 'application/json'});
}

Finder _googleIconImageFinder() {
  return find.byWidgetPredicate((widget) {
    return widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == 'assets/google_icon.png';
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.instance.clear();
  });

  testWidgets('builds sign in layout and assets', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.descendant(of: find.byType(SignInScreen), matching: find.byType(ConstrainedBox)), findsWidgets);
    expect(find.descendant(of: find.byType(SignInScreen), matching: find.byType(Column)), findsWidgets);
    expect(find.byType(Row), findsWidgets);
    expect(find.byType(Divider), findsWidgets);
    expect(find.byType(Container), findsWidgets);
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsNWidgets(2));

    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images.length, 2);
    expect((images[0].image as AssetImage).assetName, 'assets/hitmeup.jpg');
    expect((images[1].image as AssetImage).assetName, 'assets/google_icon.png');
  });

  testWidgets('shows login validation error for empty inputs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    expect(find.text('Please enter both username/email and password.'), findsOneWidget);
  });

  testWidgets('login button shows loading indicator while submitting', (tester) async {
    final completer = Completer<http.Response>();

    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        testLoginPost: (uri, {headers, body}) => completer.future,
      ),
    ));

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(await _loginResponse(200, '{"id":1,"name":"Tester"}'));
    await tester.pumpAndSettle();
  });

  testWidgets('successful login navigates to Discover and saves session', (tester) async {
    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        testLoginPost: (uri, {headers, body}) => _loginResponse(200, '{"id":1,"name":"Tester","email":"tester@example.com"}'),
      ),
      navigatorObservers: [observer],
    ));

    await tester.enterText(find.byType(TextField).at(0), 'tester@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();

    expect(find.byType(SwipeCardScreen), findsOneWidget);
    expect(AuthSession.instance.isLoggedIn, isTrue);
    expect(observer.replacedRoute, isA<MaterialPageRoute<dynamic>>());
  });

  testWidgets('invalid credentials show error message', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        testLoginPost: (uri, {headers, body}) => _loginResponse(401, '{"detail":"invalid password"}'),
      ),
    ));

    await tester.enterText(find.byType(TextField).at(0), 'tester@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect username or password'), findsOneWidget);
  });

  testWidgets('backend failure shows status message', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        testLoginPost: (uri, {headers, body}) => _loginResponse(500, '{"detail":"server down"}'),
      ),
    ));

    await tester.enterText(find.byType(TextField).at(0), 'tester@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Login failed (500): server down'), findsOneWidget);
  });

  testWidgets('google icon shows loading opacity and spinner', (tester) async {
    final completer = Completer<Map<String, dynamic>?>();

    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        testGoogleSignIn: () => completer.future,
      ),
    ));

    await tester.ensureVisible(_googleIconImageFinder());
    await tester.tap(_googleIconImageFinder());
    await tester.pump();

    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 0.5);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete({
      'status': 'linked',
      'user': {'id': 7, 'name': 'Google Tester'},
    });
    await tester.pumpAndSettle();

    expect(find.byType(SwipeCardScreen), findsOneWidget);
  });

  testWidgets('google signup required navigates to step 1 with prefills', (tester) async {
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
    expect(find.text('New User'), findsOneWidget);
    expect(find.text('new@example.com'), findsOneWidget);
  });

  testWidgets('table layout widgets are present', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.descendant(of: find.byType(SignInScreen), matching: find.byType(ConstrainedBox)), findsWidgets);
    expect(find.byType(Row), findsWidgets);
    expect(find.byType(Divider), findsWidgets);
    expect(find.byType(Opacity), findsOneWidget);
  });
}

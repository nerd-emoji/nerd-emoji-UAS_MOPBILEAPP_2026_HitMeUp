import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hitmeup/screens/splash_screen.dart';
import 'package:hitmeup/screens/auth/sign_in_screen.dart';
import 'package:hitmeup/screens/mainApp/discover.dart';
import 'package:hitmeup/services/auth_session.dart';

class _RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? replacedNewRoute;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacedNewRoute = newRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.instance.clear();
  });

  testWidgets('Splash loads and shows core widgets', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(GestureDetector), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Tap logo navigates to SignInScreen when logged out', (tester) async {
    final observer = _RecordingNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: const SplashScreen(),
      navigatorObservers: [observer],
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(observer.replacedNewRoute, isA<PageRouteBuilder<dynamic>>());
    final route = observer.replacedNewRoute as PageRouteBuilder<dynamic>;
    expect(route.transitionDuration, const Duration(milliseconds: 400));
  });

  testWidgets('Tap logo navigates to SwipeCardScreen when logged in', (tester) async {
    await AuthSession.instance.saveUser({
      'id': 2,
      'name': 'Integration User',
    });

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(find.byType(SwipeCardScreen), findsOneWidget);
  });
}

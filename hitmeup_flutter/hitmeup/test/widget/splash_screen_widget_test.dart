import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.instance.clear();
  });

  testWidgets('builds splash core widgets', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    final splashRoot = find.byType(SplashScreen);

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
    expect(find.descendant(of: splashRoot, matching: find.byType(FadeTransition)), findsOneWidget);
    expect(find.descendant(of: splashRoot, matching: find.byType(GestureDetector)), findsOneWidget);
    expect(find.descendant(of: splashRoot, matching: find.byType(ScaleTransition)), findsWidgets);
    expect(find.byType(Container), findsWidgets);
    expect(find.byType(ClipOval), findsOneWidget);
  });

  testWidgets('logo uses Image.asset with hitmeup asset', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    final provider = image.image as AssetImage;
    expect(provider.assetName, 'assets/hitmeup.jpg');
  });

  testWidgets('animation controller and curves match spec', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    final scale = tester.widget<ScaleTransition>(find.byType(ScaleTransition).first);
    final scaleAnimation = scale.scale;
    expect(scaleAnimation, isA<CurvedAnimation>());
    final scaleCurved = scaleAnimation as CurvedAnimation;
    expect(scaleCurved.curve, Curves.elasticOut);

    final parentController = scaleCurved.parent;
    expect(parentController, isA<AnimationController>());
    final controller = parentController as AnimationController;
    expect(controller.duration, const Duration(milliseconds: 800));

    final fade = tester.widget<FadeTransition>(
      find.descendant(of: find.byType(SplashScreen), matching: find.byType(FadeTransition)).first,
    );
    final fadeParent = (fade.opacity as dynamic).parent;
    expect(fadeParent, isA<CurvedAnimation>());
    expect((fadeParent as CurvedAnimation).curve, Curves.easeIn);
  });

  testWidgets('tap while checking session does not navigate yet', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(SignInScreen), findsNothing);
    expect(find.byType(SwipeCardScreen), findsNothing);
  });

  testWidgets('navigates to SignInScreen when not logged in', (tester) async {
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

  testWidgets('navigates to SwipeCardScreen when logged in', (tester) async {
    await AuthSession.instance.saveUser({
      'id': 1,
      'name': 'Tester',
      'email': 'tester@example.com',
    });

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    await tester.pumpAndSettle();
    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(find.byType(SwipeCardScreen), findsOneWidget);
  });

  testWidgets('table-mapped widgets absent in splash layout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // These table items belong to sign-in, not splash.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Divider), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('disposing splash does not leave ticker errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

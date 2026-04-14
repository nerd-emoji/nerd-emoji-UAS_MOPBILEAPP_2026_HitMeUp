import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/verification_success_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const HitMeUpApp());
}

class HitMeUpApp extends StatelessWidget {
  const HitMeUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HitMeUp',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/verification-success') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => VerificationSuccessScreen(
              email: args?['email'] ?? '',
              user: args?['user'] as Map<String, dynamic>?,
            ),
          );
        }
        return null;
      },
    );
  }
}

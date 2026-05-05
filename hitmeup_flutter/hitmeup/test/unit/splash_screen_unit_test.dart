import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/splash_screen.dart';

void main() {
  test('SplashScreen is a StatefulWidget', () {
    const widget = SplashScreen();
    expect(widget, isA<StatefulWidget>());
  });
}

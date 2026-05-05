import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/mainApp/create_community_screen.dart';

void main() {
  test('CreateCommunityScreen is a StatefulWidget', () {
    const widget = CreateCommunityScreen();
    expect(widget, isA<StatefulWidget>());
  });
}

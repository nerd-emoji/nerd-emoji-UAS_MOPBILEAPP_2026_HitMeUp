import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/signup/step1_intro_screen.dart';

void main() {
  test('constructor stores initial name and email', () {
    final widget = Step1IntroScreen(
      initialName: 'Alice',
      initialEmail: 'alice@example.com',
    );

    expect(widget.initialName, 'Alice');
    expect(widget.initialEmail, 'alice@example.com');
  });
}

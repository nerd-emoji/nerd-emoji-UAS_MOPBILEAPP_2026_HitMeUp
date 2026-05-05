import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/signup/step2_birthday_screen.dart';

void main() {
  test('constructor stores name, email, password', () {
    final now = DateTime.now();
    final widget = Step3BirthdayScreen(
      name: 'David',
      email: 'david@example.com',
      password: 'ValidPass1A',
    );

    expect(widget.name, 'David');
    expect(widget.email, 'david@example.com');
    expect(widget.password, 'ValidPass1A');
  });

  test('constructor creates state successfully', () {
    final widget = Step3BirthdayScreen(
      name: 'Eve',
      email: 'eve@example.com',
      password: 'ValidPass1B',
    );

    final state = widget.createState();
    expect(state, isNotNull);
  });

  test('testOnNavigate callback is optional and can be provided', () {
    bool callbackCalled = false;
    final widget = Step3BirthdayScreen(
      name: 'Frank',
      email: 'frank@example.com',
      password: 'ValidPass1C',
      testOnNavigate: (name, email, password, birthday, showBirthday) {
        callbackCalled = true;
      },
    );

    expect(widget.testOnNavigate, isNotNull);
  });
}

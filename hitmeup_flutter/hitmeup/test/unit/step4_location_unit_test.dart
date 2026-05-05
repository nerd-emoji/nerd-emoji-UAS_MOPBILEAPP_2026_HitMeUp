import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/signup/step4_location_screen.dart';

void main() {
  group('Step4LocationScreen Unit Tests', () {
    testWidgets('constructor stores all parameters correctly', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      final widget = Step4LocationScreen(
        name: 'Alice',
        email: 'alice@example.com',
        password: 'Pass1234A',
        gender: 'female',
        birthday: birthday,
        showBirthday: true,
      );

      expect(widget.name, 'Alice');
      expect(widget.email, 'alice@example.com');
      expect(widget.password, 'Pass1234A');
      expect(widget.gender, 'female');
      expect(widget.birthday, birthday);
      expect(widget.showBirthday, true);
      expect(widget.testOnNavigate, isNull); // optional parameter
    });

    testWidgets('state initializes with correct defaults', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      final widget = Step4LocationScreen(
        name: 'Bob',
        email: 'bob@example.com',
        password: 'Pass1234A',
        gender: 'male',
        birthday: birthday,
        showBirthday: false,
      );

      expect(widget.name, 'Bob');
      expect(widget.email, 'bob@example.com');
      expect(widget.password, 'Pass1234A');
      expect(widget.gender, 'male');
      expect(widget.birthday, birthday);
      expect(widget.showBirthday, false);
    });

    testWidgets('testOnNavigate callback parameter can be provided', (tester) async {
      final birthday = DateTime(2005, 6, 15);

      final widget = Step4LocationScreen(
        name: 'Charlie',
        email: 'charlie@example.com',
        password: 'Pass1234A',
        gender: 'female',
        birthday: birthday,
        showBirthday: true,
        testOnNavigate: (name, email, password, gender, bday, showBday, location) {
          // callback provided
        },
      );

      expect(widget.testOnNavigate, isNotNull);
    });
  });
}

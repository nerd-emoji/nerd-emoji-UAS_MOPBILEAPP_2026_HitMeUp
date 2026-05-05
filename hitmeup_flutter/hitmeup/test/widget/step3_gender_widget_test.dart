import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/signup/step3_gender_screen.dart';
import 'package:hitmeup/widgets/common_widgets.dart';

void main() {
  group('Step2GenderScreen Widget Tests', () {
    testWidgets('constructor passes parameters correctly', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      final widget = Step2GenderScreen(
        name: 'Test',
        email: 'test@example.com',
        password: 'Pass1234A',
        birthday: birthday,
        showBirthday: false,
      );

      expect(widget.name, 'Test');
      expect(widget.email, 'test@example.com');
      expect(widget.password, 'Pass1234A');
      expect(widget.birthday, birthday);
      expect(widget.showBirthday, false);
    });

    testWidgets('gender buttons and text are rendered', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step2GenderScreen(
            name: 'Charlie',
            email: 'charlie@example.com',
            password: 'Pass1234A',
            birthday: birthday,
            showBirthday: false,
          ),
        ),
      );

      expect(find.text('Woman'), findsOneWidget);
      expect(find.text('Man'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);
      expect(find.text('Your Gender'), findsOneWidget);
    });

    testWidgets('key layout widgets are present', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step2GenderScreen(
            name: 'David',
            email: 'david@example.com',
            password: 'Pass1234A',
            birthday: birthday,
            showBirthday: false,
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SignupAppBar), findsOneWidget);
      expect(find.byType(GradientBackground), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(StepIndicator), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.byType(AnimatedContainer), findsWidgets);
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Spacer), findsOneWidget);
    });

    testWidgets('callback parameter can be provided', (tester) async {
      final birthday = DateTime(2005, 6, 15);

      final widget = Step2GenderScreen(
        name: 'Eve',
        email: 'eve@example.com',
        password: 'Pass1234A',
        birthday: birthday,
        showBirthday: false,
        testOnNavigate: (name, email, password, bday, showBday, gender) {
          // callback provided
        },
      );

      expect(widget.testOnNavigate, isNotNull);
    });

    testWidgets('optional parameters work correctly', (tester) async {
      final birthday = DateTime(2005, 6, 15);

      final widget = Step2GenderScreen(
        name: 'Frank',
        email: 'frank@example.com',
        password: 'Pass1234A',
        birthday: birthday,
        showBirthday: true,
      );

      expect(widget.testOnNavigate, isNull);
      expect(widget.showBirthday, true);
    });
  });
}

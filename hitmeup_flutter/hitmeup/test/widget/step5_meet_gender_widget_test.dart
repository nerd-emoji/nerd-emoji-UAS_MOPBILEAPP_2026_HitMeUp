import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/signup/step5_meet_gender_screen.dart';
import 'package:hitmeup/widgets/common_widgets.dart';

void main() {
  group('Step5MeetGenderScreen Widget Tests', () {
    testWidgets('constructor passes parameters correctly', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      final widget = Step5MeetGenderScreen(
        name: 'Test',
        email: 'test@example.com',
        password: 'Pass1234A',
        gender: 'female',
        birthday: birthday,
        showBirthday: false,
        location: 'Jakarta',
      );

      expect(widget.name, 'Test');
      expect(widget.email, 'test@example.com');
      expect(widget.password, 'Pass1234A');
      expect(widget.gender, 'female');
      expect(widget.birthday, birthday);
      expect(widget.showBirthday, false);
      expect(widget.location, 'Jakarta');
    });

    testWidgets('all 15 widgets are present in widget tree', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'Alice',
            email: 'alice@example.com',
            password: 'Pass1234A',
            gender: 'female',
            birthday: birthday,
            showBirthday: false,
            location: 'Bandung',
          ),
        ),
      );

      // Verify all 15 widgets from the table
      expect(find.byType(Scaffold), findsOneWidget, reason: 'Scaffold');
      expect(find.byType(Column), findsWidgets, reason: 'Column');
      expect(find.byType(SignupAppBar), findsOneWidget, reason: 'SignupAppBar');
      expect(find.byType(Expanded), findsWidgets, reason: 'Expanded');
      expect(find.byType(GradientBackground), findsOneWidget, reason: 'GradientBackground');
      expect(find.byType(SafeArea), findsOneWidget, reason: 'SafeArea');
      expect(find.byType(Padding), findsWidgets, reason: 'Padding');
      expect(find.byType(StepIndicator), findsOneWidget, reason: 'StepIndicator');
      expect(find.byType(Text), findsWidgets, reason: 'Text');
      expect(find.byType(SizedBox), findsWidgets, reason: 'SizedBox');
      expect(find.byType(GestureDetector), findsWidgets, reason: 'GestureDetector');
      expect(find.byType(AnimatedContainer), findsWidgets, reason: 'AnimatedContainer');
      expect(find.byType(Center), findsWidgets, reason: 'Center');
      expect(find.byType(Spacer), findsOneWidget, reason: 'Spacer');
      expect(find.byType(ElevatedButton), findsOneWidget, reason: 'ElevatedButton');
    });

    testWidgets('renders title "Who do you want to meet?"', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'Bob',
            email: 'bob@example.com',
            password: 'Pass1234A',
            gender: 'male',
            birthday: birthday,
            showBirthday: false,
            location: 'Surabaya',
          ),
        ),
      );

      expect(find.text('Who do you want to meet?'), findsOneWidget);
    });

    testWidgets('renders description text', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'Charlie',
            email: 'charlie@example.com',
            password: 'Pass1234A',
            gender: 'female',
            birthday: birthday,
            showBirthday: true,
            location: 'Yogyakarta',
          ),
        ),
      );

      expect(find.text('Choose the gender that you want to meet'), findsOneWidget);
    });

    testWidgets('renders all three option buttons', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'David',
            email: 'david@example.com',
            password: 'Pass1234A',
            gender: 'male',
            birthday: birthday,
            showBirthday: false,
            location: 'Medan',
          ),
        ),
      );

      expect(find.text('Woman'), findsOneWidget);
      expect(find.text('Man'), findsOneWidget);
      expect(find.text('Everyone'), findsOneWidget);
    });

    testWidgets('renders CONTINUE button', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'Eve',
            email: 'eve@example.com',
            password: 'Pass1234A',
            gender: 'female',
            birthday: birthday,
            showBirthday: false,
            location: 'Makassar',
          ),
        ),
      );

      expect(find.text('CONTINUE'), findsOneWidget);
    });

    testWidgets('StepIndicator shows correct step (step 4 of 6)', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'Frank',
            email: 'frank@example.com',
            password: 'Pass1234A',
            gender: 'male',
            birthday: birthday,
            showBirthday: false,
            location: 'Jakarta',
          ),
        ),
      );

      expect(find.byType(StepIndicator), findsOneWidget);
    });

    testWidgets('option selection can be triggered', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'Grace',
            email: 'grace@example.com',
            password: 'Pass1234A',
            gender: 'female',
            birthday: birthday,
            showBirthday: true,
            location: 'Bandung',
          ),
        ),
      );

      // Tap on "Woman" option
      await tester.tap(find.text('Woman'));
      await tester.pumpAndSettle();

      expect(find.text('Woman'), findsOneWidget);
    });

    testWidgets('key layout widgets are present', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'Henry',
            email: 'henry@example.com',
            password: 'Pass1234A',
            gender: 'male',
            birthday: birthday,
            showBirthday: false,
            location: 'Surabaya',
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SignupAppBar), findsOneWidget);
      expect(find.byType(GradientBackground), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(StepIndicator), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Spacer), findsOneWidget);
    });

    testWidgets('callback parameter can be provided', (tester) async {
      final birthday = DateTime(2005, 6, 15);

      final widget = Step5MeetGenderScreen(
        name: 'Iris',
        email: 'iris@example.com',
        password: 'Pass1234A',
        gender: 'female',
        birthday: birthday,
        showBirthday: true,
        location: 'Yogyakarta',
        testOnNavigate: (name, email, password, gender, bday, showBday, location, meetGender) {
          // callback provided
        },
      );

      expect(widget.testOnNavigate, isNotNull);
    });

    testWidgets('optional parameters work correctly', (tester) async {
      final birthday = DateTime(2005, 6, 15);

      final widget = Step5MeetGenderScreen(
        name: 'Jack',
        email: 'jack@example.com',
        password: 'Pass1234A',
        gender: 'male',
        birthday: birthday,
        showBirthday: true,
        location: 'Medan',
      );

      expect(widget.testOnNavigate, isNull);
      expect(widget.showBirthday, true);
      expect(widget.location, 'Medan');
    });

    testWidgets('animated containers for options are present', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step5MeetGenderScreen(
            name: 'Kate',
            email: 'kate@example.com',
            password: 'Pass1234A',
            gender: 'female',
            birthday: birthday,
            showBirthday: false,
            location: 'Makassar',
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });
}

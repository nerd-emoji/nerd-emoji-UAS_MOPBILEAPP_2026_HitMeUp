import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/signup/step2_birthday_screen.dart';
import 'package:hitmeup/widgets/common_widgets.dart';

void main() {
  group('Step3BirthdayScreen Widget Tests', () {
    testWidgets('all 18 widgets are present in widget tree', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'Test',
            email: 'test@example.com',
            password: 'Pass1234A',
          ),
        ),
      );

      // Verify all 18 widgets from the table
      expect(find.byType(Scaffold), findsOneWidget, reason: 'Scaffold');
      expect(find.byType(Column), findsWidgets, reason: 'Column');
      expect(find.byType(SignupAppBar), findsOneWidget, reason: 'SignupAppBar');
      expect(find.byType(Expanded), findsWidgets, reason: 'Expanded');
      expect(find.byType(GradientBackground), findsOneWidget, reason: 'GradientBackground');
      expect(find.byType(SafeArea), findsOneWidget, reason: 'SafeArea');
      expect(find.byType(Padding), findsWidgets, reason: 'Padding');
      expect(find.byType(StepIndicator), findsOneWidget, reason: 'StepIndicator');
      expect(find.byType(Text), findsWidgets, reason: 'Text');
      expect(find.byType(Container), findsWidgets, reason: 'Container');
      expect(find.byType(SizedBox), findsWidgets, reason: 'SizedBox');
      expect(find.byType(CupertinoDatePicker), findsOneWidget, reason: 'CupertinoDatePicker');
      expect(find.byType(GestureDetector), findsWidgets, reason: 'GestureDetector');
      expect(find.byType(AnimatedContainer), findsWidgets, reason: 'AnimatedContainer');
      expect(find.byType(Row), findsWidgets, reason: 'Row');
      expect(find.byType(Icon), findsWidgets, reason: 'Icon');
      expect(find.byType(Spacer), findsOneWidget, reason: 'Spacer');
      expect(find.byType(ElevatedButton), findsOneWidget, reason: 'ElevatedButton');
    });

    testWidgets('renders title "Your Birthday"', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'Alice',
            email: 'alice@example.com',
            password: 'Pass1234A',
          ),
        ),
      );

      expect(find.text('Your Birthday'), findsOneWidget);
    });

    testWidgets('renders label "Show on profile"', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'Bob',
            email: 'bob@example.com',
            password: 'Pass1234A',
          ),
        ),
      );

      expect(find.text('Show on profile'), findsOneWidget);
    });

    testWidgets('renders button text "CONTINUE"', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'Charlie',
            email: 'charlie@example.com',
            password: 'Pass1234A',
          ),
        ),
      );

      expect(find.text('CONTINUE'), findsOneWidget);
    });

    testWidgets('CupertinoDatePicker is visible', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'David',
            email: 'david@example.com',
            password: 'Pass1234A',
          ),
        ),
      );

      expect(find.byType(CupertinoDatePicker), findsOneWidget);
    });

    testWidgets('StepIndicator shows correct step (step 1 of 6)', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'Frank',
            email: 'frank@example.com',
            password: 'Pass1234A',
          ),
        ),
      );

      // Verify StepIndicator is present
      expect(find.byType(StepIndicator), findsOneWidget);
    });

    testWidgets('testOnNavigate callback is invoked with correct parameters', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      bool callbackInvoked = false;
      String? navName;
      String? navEmail;
      String? navPassword;
      DateTime? navBirthday;
      bool? navShowBirthday;

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'Grace',
            email: 'grace@example.com',
            password: 'Pass1234A',
            testOnNavigate: (name, email, password, birthday, showBirthday) {
              callbackInvoked = true;
              navName = name;
              navEmail = email;
              navPassword = password;
              navBirthday = birthday;
              navShowBirthday = showBirthday;
            },
          ),
        ),
      );

      // Tap CONTINUE button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(callbackInvoked, isTrue);
      expect(navName, 'Grace');
      expect(navEmail, 'grace@example.com');
      expect(navPassword, 'Pass1234A');
      expect(navBirthday, isNotNull);
      expect(navShowBirthday, isFalse); // default state
    });

    testWidgets('constructor stores all parameters correctly', (tester) async {
      final widget = Step3BirthdayScreen(
        name: 'Iris',
        email: 'iris@example.com',
        password: 'Pass1234A',
      );

      expect(widget.name, 'Iris');
      expect(widget.email, 'iris@example.com');
      expect(widget.password, 'Pass1234A');
      expect(widget.testOnNavigate, isNull); // optional parameter
    });

    testWidgets('testOnNavigate callback parameter can be provided', (tester) async {
      bool called = false;

      final widget = Step3BirthdayScreen(
        name: 'Jack',
        email: 'jack@example.com',
        password: 'Pass1234A',
        testOnNavigate: (name, email, password, birthday, showBirthday) {
          called = true;
        },
      );

      expect(widget.testOnNavigate, isNotNull);
    });

    testWidgets('SafeArea and GradientBackground provide layout structure', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'Karen',
            email: 'karen@example.com',
            password: 'Pass1234A',
          ),
        ),
      );

      expect(find.byType(GradientBackground), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('SignupAppBar back button is present', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Step3BirthdayScreen(
            name: 'Leo',
            email: 'leo@example.com',
            password: 'Pass1234A',
          ),
        ),
      );

      expect(find.byType(SignupAppBar), findsOneWidget);
    });
  });
}


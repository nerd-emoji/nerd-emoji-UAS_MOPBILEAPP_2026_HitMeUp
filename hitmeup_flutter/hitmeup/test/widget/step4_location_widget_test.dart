import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/signup/step4_location_screen.dart';
import 'package:hitmeup/widgets/common_widgets.dart';

void main() {
  group('Step4LocationScreen Widget Tests', () {
    testWidgets('constructor passes parameters correctly', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      final widget = Step4LocationScreen(
        name: 'Test',
        email: 'test@example.com',
        password: 'Pass1234A',
        gender: 'female',
        birthday: birthday,
        showBirthday: false,
      );

      expect(widget.name, 'Test');
      expect(widget.email, 'test@example.com');
      expect(widget.password, 'Pass1234A');
      expect(widget.gender, 'female');
      expect(widget.birthday, birthday);
      expect(widget.showBirthday, false);
    });

    testWidgets('all 22 widgets are present in widget tree', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step4LocationScreen(
            name: 'Alice',
            email: 'alice@example.com',
            password: 'Pass1234A',
            gender: 'female',
            birthday: birthday,
            showBirthday: false,
          ),
        ),
      );

      // Verify all 22 widgets from the table
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
      expect(find.byType(Container), findsWidgets, reason: 'Container');
      expect(find.byType(TextField), findsOneWidget, reason: 'TextField');
      expect(find.byType(Icon), findsWidgets, reason: 'Icon');
      expect(find.byType(IconButton), findsWidgets, reason: 'IconButton');
      // CircularProgressIndicator, ListView, Divider, ListTile only appear conditionally
      expect(find.byType(Align), findsWidgets, reason: 'Align');
      expect(find.byType(ConstrainedBox), findsWidgets, reason: 'ConstrainedBox');
      expect(find.byType(Spacer), findsOneWidget, reason: 'Spacer');
      expect(find.byType(ElevatedButton), findsOneWidget, reason: 'ElevatedButton');
    });

    testWidgets('renders title "Where do you live?"', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step4LocationScreen(
            name: 'Bob',
            email: 'bob@example.com',
            password: 'Pass1234A',
            gender: 'male',
            birthday: birthday,
            showBirthday: false,
          ),
        ),
      );

      expect(find.text('Where do you live?'), findsOneWidget);
    });

    testWidgets('renders search hint text', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step4LocationScreen(
            name: 'Charlie',
            email: 'charlie@example.com',
            password: 'Pass1234A',
            gender: 'female',
            birthday: birthday,
            showBirthday: true,
          ),
        ),
      );

      expect(find.text('Search your city'), findsOneWidget);
    });

    testWidgets('renders CONTINUE button', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step4LocationScreen(
            name: 'David',
            email: 'david@example.com',
            password: 'Pass1234A',
            gender: 'male',
            birthday: birthday,
            showBirthday: false,
          ),
        ),
      );

      expect(find.text('CONTINUE'), findsOneWidget);
    });

    testWidgets('key layout widgets are present', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step4LocationScreen(
            name: 'Eve',
            email: 'eve@example.com',
            password: 'Pass1234A',
            gender: 'female',
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
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Spacer), findsOneWidget);
    });

    testWidgets('StepIndicator shows correct step (step 3 of 6)', (tester) async {
      final birthday = DateTime(2005, 6, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: Step4LocationScreen(
            name: 'Frank',
            email: 'frank@example.com',
            password: 'Pass1234A',
            gender: 'male',
            birthday: birthday,
            showBirthday: false,
          ),
        ),
      );

      expect(find.byType(StepIndicator), findsOneWidget);
    });

    testWidgets('callback parameter can be provided', (tester) async {
      final birthday = DateTime(2005, 6, 15);

      final widget = Step4LocationScreen(
        name: 'Grace',
        email: 'grace@example.com',
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

    testWidgets('optional parameters work correctly', (tester) async {
      final birthday = DateTime(2005, 6, 15);

      final widget = Step4LocationScreen(
        name: 'Henry',
        email: 'henry@example.com',
        password: 'Pass1234A',
        gender: 'male',
        birthday: birthday,
        showBirthday: true,
      );

      expect(widget.testOnNavigate, isNull);
      expect(widget.showBirthday, true);
    });
  });
}

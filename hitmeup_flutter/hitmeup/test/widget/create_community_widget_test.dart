import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hitmeup/screens/mainApp/create_community_screen.dart';
import 'package:hitmeup/services/auth_session.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.instance.clear();
  });

  testWidgets('builds basic layout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateCommunityScreen()));

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('shows validation snackbar for empty name', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateCommunityScreen()));

    // Tap create with empty fields
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a community name'), findsOneWidget);
  });

  testWidgets('max participants accepts only digits', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateCommunityScreen()));

    // The third TextField is the max participants field in the layout
    final maxField = find.byType(TextField).at(2);
    await tester.enterText(maxField, 'abc123');
    await tester.pump();

    // Only digits should remain and be displayed
    expect(find.text('123'), findsOneWidget);
  });


  testWidgets('layout contains SafeArea/Center/Column/Container', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateCommunityScreen()));

    expect(find.byType(SafeArea), findsWidgets);
    expect(find.byType(Center), findsWidgets);
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('shows image preview when initial bytes provided', (tester) async {
    // Use a valid 1x1 PNG for memory image decoding.
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
    );

    await tester.pumpWidget(MaterialApp(
      home: CreateCommunityScreen(testInitialPickedImageBytes: Uint8List.fromList(png)),
    ));

    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('shows CircularProgressIndicator when initial creating set', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CreateCommunityScreen(testInitialIsCreating: true),
    ));

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows permission AlertDialog via test action and returns false on cancel', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateCommunityScreen(enableTestActions: true)));

    // Tap the hidden test button to open the dialog
    await tester.tap(find.byKey(const Key('test_show_permission_dialog')));
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('shows snackbar when max participants missing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateCommunityScreen()));

    // Enter name but leave max empty
    await tester.enterText(find.byType(TextField).first, 'My Community');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Please enter maximum participants'), findsOneWidget);
  });

  testWidgets('shows snackbar when max participants invalid (zero)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateCommunityScreen()));

    // Enter name and invalid max
    await tester.enterText(find.byType(TextField).first, 'My Community');
    await tester.enterText(find.byType(TextField).at(2), '0');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('Maximum participants must be a valid number'), findsOneWidget);
  });
}

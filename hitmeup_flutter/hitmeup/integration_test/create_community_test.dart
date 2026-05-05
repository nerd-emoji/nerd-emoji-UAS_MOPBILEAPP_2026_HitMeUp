import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hitmeup/screens/mainApp/create_community_screen.dart';
import 'package:hitmeup/services/auth_session.dart';
import 'dart:typed_data';

Future<Map<String, dynamic>> _fakeCreateSuccess({
  required String name,
  required String description,
  required int maxParticipants,
  Uint8List? communityPictureBytes,
  String? pictureName,
}) async {
  // Simulate network delay
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return {'id': 123};
}

Future<Map<String, dynamic>> _fakeCreateFailure({
  required String name,
  required String description,
  required int maxParticipants,
  Uint8List? communityPictureBytes,
  String? pictureName,
}) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  throw Exception('create failed');
}

Future<void> _fakeAddUserFail({required int userId, required int communityId}) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  throw Exception('add user failed');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create community screen integration smoke test', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateCommunityScreen(testCreateCommunity: _fakeCreateSuccess)));

    // Basic smoke checks
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));

    // Validate snackbar on empty submit
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a community name'), findsOneWidget);
  });

  testWidgets('successful create shows success snackbar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CreateCommunityScreen(testCreateCommunity: _fakeCreateSuccess),
    ));

    // Fill form
    await tester.enterText(find.byType(TextField).first, 'My Community');
    await tester.enterText(find.byType(TextField).at(1), 'desc');
    await tester.enterText(find.byType(TextField).at(2), '10');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('created successfully'), findsOneWidget);
  });

  testWidgets('create failure shows error snackbar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CreateCommunityScreen(testCreateCommunity: _fakeCreateFailure),
    ));

    await tester.enterText(find.byType(TextField).first, 'My Community');
    await tester.enterText(find.byType(TextField).at(1), 'desc');
    await tester.enterText(find.byType(TextField).at(2), '10');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to create community'), findsOneWidget);
  });

  testWidgets('add-user failure shows warning snackbar', (tester) async {
    // Save a user in session so addUser is attempted
    await tester.pumpWidget(MaterialApp(home: CreateCommunityScreen(
      testCreateCommunity: _fakeCreateSuccess,
      testAddUserToCommunity: _fakeAddUserFail,
    )));

    // simulate logged-in user
    await AuthSession.instance.saveUser({'id': 7, 'name': 'T'});

    await tester.enterText(find.byType(TextField).first, 'My Community');
    await tester.enterText(find.byType(TextField).at(1), 'desc');
    await tester.enterText(find.byType(TextField).at(2), '10');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Warning: Could not add you as a member'), findsOneWidget);
  });
}

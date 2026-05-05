import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hitmeup/screens/mainApp/community.dart';
import 'package:hitmeup/screens/mainApp/community_chat_screen.dart';
import 'package:hitmeup/services/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/community_http_mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.instance.saveUser({
      'id': 1,
      'name': 'Tester',
      'diamonds': 17,
    });
  });

  testWidgets('Community screen loads and can join a community', (tester) async {
    CommunityHttpMocks.reset();

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CommunityScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Sample Community'), findsOneWidget);

      await tester.tap(find.text('Sample Community'));
      await tester.pumpAndSettle();

      expect(find.text('Do you want to join this community?'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(CommunityHttpMocks.addMemberCalls, 1);
      expect(find.byType(CommunityChatScreen), findsOneWidget);
    }, createHttpClient: (_) => CommunityHttpMocks.createHttpClient());
  });
}
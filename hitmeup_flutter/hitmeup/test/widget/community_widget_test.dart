import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/screens/mainApp/community.dart';
import 'package:hitmeup/services/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/community_http_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.instance.clear();
  });

  Future<void> runCommunityScenario(
    WidgetTester tester, {
    required CommunityHttpScenario scenario,
    Duration responseDelay = Duration.zero,
    required Future<void> Function() body,
  }) async {
    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CommunityScreen(),
        ),
      );

      if (responseDelay > Duration.zero) {
        await tester.pump(responseDelay ~/ 2);
      } else {
        await tester.pump();
      }

      await body();
    }, createHttpClient: (_) {
      return CommunityHttpMocks.createHttpClient(
        scenario: scenario,
      );
    });
  }

  Future<void> runCommunityScenarioWithAuth(
    WidgetTester tester, {
    required CommunityHttpScenario scenario,
    Duration responseDelay = Duration.zero,
    required Future<void> Function() body,
  }) async {
    await AuthSession.instance.saveUser({
      'id': 1,
      'name': 'Tester',
      'diamonds': 17,
    });
    await runCommunityScenario(
      tester,
      scenario: scenario,
      responseDelay: responseDelay,
      body: body,
    );
  }

  testWidgets('shows loading indicator before data arrives', (tester) async {
    await runCommunityScenario(
      tester,
      scenario: CommunityHttpScenario.delayedSuccess,
      responseDelay: const Duration(milliseconds: 200),
      body: () async {
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('Community'), findsOneWidget);
        expect(find.text('Sample Community'), findsOneWidget);
      },
    );
  });

  testWidgets('shows empty state when there are no communities', (tester) async {
    await runCommunityScenario(
      tester,
      scenario: CommunityHttpScenario.empty,
      body: () async {
        await tester.pumpAndSettle();

        expect(find.text('No communities available'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
      },
    );
  });

  testWidgets('shows error state and retry button on fetch failure', (tester) async {
    await runCommunityScenario(
      tester,
      scenario: CommunityHttpScenario.fetchError,
      body: () async {
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.textContaining('Failed to load communities:'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );
  });

  testWidgets('loads communities and opens join dialog', (tester) async {
    await runCommunityScenarioWithAuth(
      tester,
      scenario: CommunityHttpScenario.success,
      body: () async {
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Community'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Sample Community'), findsOneWidget);
        expect(find.text('Other Community'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'other');
        await tester.pump();

        expect(find.text('Sample Community'), findsNothing);
        expect(find.text('Other Community'), findsOneWidget);

        await tester.enterText(find.byType(TextField), '');
        await tester.pump();

        await tester.tap(find.text('Sample Community'));
        await tester.pumpAndSettle();

        expect(find.text('Do you want to join this community?'), findsOneWidget);
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(ClipOval), findsOneWidget);
        expect(find.byType(Image), findsWidgets);
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Do you want to join this community?'), findsNothing);
      },
    );
  });

  testWidgets('shows login snackbar when joining without session', (tester) async {
    await runCommunityScenario(
      tester,
      scenario: CommunityHttpScenario.success,
      body: () async {
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sample Community'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.check_rounded));
        await tester.pump();

        expect(find.text('Please log in to join communities.'), findsOneWidget);
      },
    );
  });

  testWidgets('shows join failure snackbar when add member fails', (tester) async {
    await runCommunityScenarioWithAuth(
      tester,
      scenario: CommunityHttpScenario.joinError,
      body: () async {
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sample Community'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.check_rounded));
        await tester.pumpAndSettle();

        expect(
          find.text('Failed to join community. Please try again.'),
          findsOneWidget,
        );
      },
    );
  });

  testWidgets('back button is visible for navigation', (tester) async {
    await runCommunityScenarioWithAuth(
      tester,
      scenario: CommunityHttpScenario.success,
      body: () async {
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      },
    );
  });
}

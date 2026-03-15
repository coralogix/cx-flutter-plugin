import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:coralogix_sdk/main.dart' as app;
import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dio Network Tracking Tests', () {
    setUpAll(() async {
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        debugPrint('Warning: Could not load .env file: $e');
      }
    });

    testWidgets('Dio GET button is present and tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: app.MyApp()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final found = await scrollToElement(tester, 'dio-get-button');
      expect(found, isTrue, reason: 'Dio GET button should be visible');

      await tester.tap(find.byKey(const Key('dio-get-button')));
      // Allow time for the Dio request to complete and the RUM event to be dispatched.
      await tester.pumpAndSettle(const Duration(seconds: 3));
      // No crash = pass; full network payload is verified via SDK dashboard in e2e tests.
    });

    testWidgets('Dio POST button is present and tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: app.MyApp()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final found = await scrollToElement(tester, 'dio-post-button');
      expect(found, isTrue, reason: 'Dio POST button should be visible');

      await tester.tap(find.byKey(const Key('dio-post-button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Dio error button is present and does not crash the app', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: app.MyApp()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final found = await scrollToElement(tester, 'dio-error-button');
      expect(found, isTrue, reason: 'Dio error button should be visible');

      await tester.tap(find.byKey(const Key('dio-error-button')));
      // Error requests should not crash the app — the onError path must be handled gracefully.
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}

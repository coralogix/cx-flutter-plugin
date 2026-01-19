import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:coralogix_sdk/main.dart' as app;
import 'helpers.dart';

/// Helper to extract text from InlineSpan
String extractTextFromInlineSpan(dynamic span) {
  if (span == null) return '';
  if (span is TextSpan) {
    return span.toPlainText();
  }
  if (span is String) {
    return span;
  }
  return span.toString();
}

/// Handles validation errors by adding them to failed tests and printing a summary
void _handleValidationErrors(
  List<String> errors,
  String? sessionId,
  List<String> failedTests,
) {
  final errorMessage = 'Log Validation: ${errors.length} log(s) failed validation:\n'
      '${errors.join('\n')}\n'
      'Session ID: $sessionId';
  
  failedTests.add(errorMessage);
  
  // Print detailed validation error summary
  _printSectionHeader('❌ LOG VALIDATION FAILURE SUMMARY');
  debugPrint('Failed Validations (${errors.length}):');
  for (int i = 0; i < errors.length; i++) {
    debugPrint('  ${i + 1}. ${errors[i]}');
  }
  debugPrint('Session ID: $sessionId');
  _printSectionFooter();
}

/// Prints a section header with separator line
void _printSectionHeader(String title) {
  debugPrint('');
  debugPrint('=' * 80);
  debugPrint(title);
  debugPrint('=' * 80);
}

/// Prints a section footer with separator line
void _printSectionFooter() {
  debugPrint('=' * 80);
  debugPrint('');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Coralogix SDK E2E Tests', () {
    String? sessionId;
    final List<String> failedTests = [];

    setUpAll(() async {
      // Launch app once and wait for readiness
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      // Load environment variables before running tests
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        debugPrint('Warning: Could not load .env file: $e');
        debugPrint('Make sure .env file exists in the example directory');
      }
    });

    setUp(() async {
      // Ensure sessionId is preserved across tests
      // It will be set in the first test
    });

    testWidgets('App launches and session ID is available', (WidgetTester tester) async {
      // Launch the app - need to wrap in MaterialApp since MyApp returns Scaffold
      await tester.pumpWidget(
        const MaterialApp(
          home: app.MyApp(),
        ),
      );
     
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Poll until session ID is not "Loading..." and not empty
      await waitForCondition(
        tester,
        () {
          try {
            final sessionIdFinder = find.byKey(const Key('session-id'));
            if (!tester.any(sessionIdFinder)) {
              return false;
            }

            // Try to get text from SelectableText or Text widget
            try {
              final selectableTextWidget = tester.widget<SelectableText>(sessionIdFinder);
              final currentSessionId = extractTextFromInlineSpan(selectableTextWidget.data);
              return currentSessionId.isNotEmpty && 
                     currentSessionId != 'Loading...' &&
                     currentSessionId.toLowerCase() != 'loading' &&
                     currentSessionId != 'Session ID not available';
            } catch (e) {
              try {
                final textWidget = tester.widget<Text>(sessionIdFinder);
                final currentSessionId = textWidget.data ?? '';
                return currentSessionId.isNotEmpty && 
                       currentSessionId != 'Loading...' &&
                       currentSessionId.toLowerCase() != 'loading' &&
                       currentSessionId != 'Session ID not available';
              } catch (e2) {
                return false;
              }
            }
          } catch (e) {
            return false;
          }
        },
        timeout: const Duration(seconds: 30),
        interval: const Duration(milliseconds: 500),
        errorMessage: 'Session ID did not become available',
      );

      // Read session ID from UI
      final sessionIdFinder = find.byKey(const Key('session-id'));
      expect(sessionIdFinder, findsOneWidget);
      
      // Try SelectableText first, then Text
      try {
        final selectableTextWidget = tester.widget<SelectableText>(sessionIdFinder);
        final extracted = extractTextFromInlineSpan(selectableTextWidget.data);
        sessionId = extracted.isEmpty ? null : extracted;
      } catch (e) {
        final textWidget = tester.widget<Text>(sessionIdFinder);
        sessionId = textWidget.data;
      }
      
      expect(sessionId, isNotNull);
      expect(sessionId, isNotEmpty);
      expect(sessionId, isNot('Loading...'));
      
      debugPrint('Session ID captured: $sessionId');
    });

    testWidgets('Network Success Button', (WidgetTester tester) async {
      try {
        await prepareAppForTest(tester);
        await clickOnElement(tester, 'network-success-button');
      } catch (e) {
        failedTests.add('Network Success Button: $e');
        rethrow;
      }
    });

    testWidgets('Network Failure Button', (WidgetTester tester) async {
      try {
        await prepareAppForTest(tester);
        await clickOnElement(tester, 'network-failure-button');
      } catch (e) {
        failedTests.add('Network Failure Button: $e');
        rethrow;
      }
    });

    testWidgets('Report Error Button', (WidgetTester tester) async {
      try {
        await prepareAppForTest(tester);
        await clickOnElement(tester, 'report-error-button', expectDialog: true);
      } catch (e) {
        failedTests.add('Report Error Button: $e');
        rethrow;
      }
    });
    testWidgets('Send Info Log Button', (WidgetTester tester) async {
      try {
        await prepareAppForTest(tester);
        // Note: Using send-error-log-button as there's no separate info log button
        await clickOnElement(tester, 'send-error-log-button');
      } catch (e) {
        failedTests.add('Send Info Log Button: $e');
        rethrow;
      }
    });

    testWidgets('Send Custom Measurement Button', (WidgetTester tester) async {
      try {
        await prepareAppForTest(tester);
        await clickOnElement(tester, 'send-custom-measurement-button');
      } catch (e) {
        failedTests.add('Send Custom Measurement Button: $e');
        rethrow;
      }
    });

    testWidgets('Error with Custom Labels Button', (WidgetTester tester) async {
      try {
        await prepareAppForTest(tester);
        // This might be the "Throw Exception" button or similar
        await clickOnElement(tester, 'error-with-custom-labels-button');
      } catch (e) {
        failedTests.add('Error with Custom Labels Button: $e');
        rethrow;
      }
    });

    testWidgets('Verify Logs Button', (WidgetTester tester) async {
      try {
        await prepareAppForTest(tester);
        await clickOnElement(tester, 'verify-logs-button', expectDialog: true);
      } catch (e) {
        failedTests.add('Verify Logs Button: $e');
        rethrow;
      }
    });

    tearDownAll(() async {
      // Poll HTTP endpoint until logs exist, then validate
      if (sessionId == null || sessionId!.isEmpty) {
        debugPrint('Warning: Session ID not available for validation. Skipping validation.');
        return;
      }

      debugPrint('Starting log validation for session: $sessionId');

      // Poll until logs are available
      final validationUrl = 'https://schema-validator-latest.onrender.com/logs/validate/$sessionId';
      const maxPollAttempts = 30;
      const pollInterval = Duration(seconds: 2);
      
      List<dynamic>? validationData;
      
      for (int attempt = 0; attempt < maxPollAttempts; attempt++) {
        try {
          final response = await http.get(
            Uri.parse(validationUrl),
            headers: {'Accept': 'application/json'},
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

          if (response.statusCode == 200) {
            final decoded = json.decode(response.body);
            if (decoded is List && decoded.isNotEmpty) {
              validationData = decoded;
              debugPrint('Logs found after ${attempt + 1} attempts');
              break;
            }
          }
        } catch (e) {
          debugPrint('Poll attempt ${attempt + 1} failed: $e');
        }

        if (attempt < maxPollAttempts - 1) {
          await Future.delayed(pollInterval);
        }
      }

      if (validationData == null || validationData.isEmpty) {
        throw Exception(
          'No logs found for validation after $maxPollAttempts attempts. '
          'Session ID: $sessionId'
        );
      }

      // Validate each log entry
      final List<String> errors = [];
      
      for (final item in validationData) {
        try {
          if (item is! Map<String, dynamic>) {
            errors.add('Invalid item format: $item');
            continue;
          }

          final validationResult = item['validationResult'];
          if (validationResult is! Map<String, dynamic>) {
            errors.add('Invalid validationResult format: $validationResult');
            continue;
          }

          final statusCode = validationResult['statusCode'];
          final message = validationResult['message'];

          if (statusCode != 200) {
            final errorMsg = message is String 
                ? message 
                : 'Invalid status code: $statusCode';
            errors.add(errorMsg);
          }
        } catch (e) {
          errors.add('Error processing validation item: $e');
        }
      }

      // Handle validation results
      if (errors.isNotEmpty) {
        _handleValidationErrors(errors, sessionId, failedTests);
      } else {
        debugPrint('✅ All ${validationData.length} logs validated successfully!');
      }

      if (failedTests.isNotEmpty) {
        throw Exception(
          'Test failures detected:\n${failedTests.join('\n')}',
        );
      }
    });
  });
}


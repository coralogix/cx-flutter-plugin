import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:coralogix_sdk/main.dart' as app;
import 'helpers.dart';

const double _scrollDelta = 500.0;
const int _maxScrollAttempts = 10;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Interaction Tracking Tests', () {
    String? sessionId;
    final List<String> failedTests = [];

    setUpAll(() async {
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        debugPrint('Warning: Could not load .env file: $e');
      }
    });

    testWidgets('Navigate to Interaction Demo page and capture session', (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: app.MyApp(),
          ),
        );
       
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Wait for session to be ready
        final sessionIdFinder = find.byKey(const Key('session-id'));
        await waitForElement(
          tester,
          sessionIdFinder,
          timeout: const Duration(seconds: 30),
        );
        
        await tester.pump(const Duration(seconds: 2));

        // Capture session ID for schema validation
        try {
          final selectableTextWidget = tester.widget<SelectableText>(sessionIdFinder);
          final text = selectableTextWidget.data;
          if (text != null && text.isNotEmpty && text != 'Loading...') {
            sessionId = text;
          }
        } catch (e) {
          try {
            final textWidget = tester.widget<Text>(sessionIdFinder);
            sessionId = textWidget.data;
          } catch (e2) {
            debugPrint('Could not capture session ID: $e2');
          }
        }
        
        debugPrint('Session ID captured: $sessionId');

        // Navigate to Interaction Demo page - it's at the very bottom of the list
        final listFinder = find.byKey(const Key('sdk-options-list'));
        final interactionDemoText = find.text('Interaction Tracking Demo');
        
        // Scroll down until the button is visible
        final found = await _scrollToTargetVisible(tester, listFinder, interactionDemoText);
        
        if (!found) {
          throw Exception('Could not scroll to Interaction Tracking Demo button');
        }
        
        // Tap the card containing the text
        await tester.tap(interactionDemoText);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Wait for the Interaction Demo page to load
        await waitForElement(
          tester,
          find.byKey(const ValueKey('elevated_btn')),
          timeout: const Duration(seconds: 10),
        );
        
        // Verify we're on the Interaction Demo page
        expect(find.byKey(const ValueKey('elevated_btn')), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Navigate to Interaction Demo: $e');
        rethrow;
      }
    });

    testWidgets('Click event schema validation - ElevatedButton', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        // Find and tap the ElevatedButton
        final elevatedButton = find.byKey(const ValueKey('elevated_btn'));
        expect(elevatedButton, findsOneWidget);
        
        await tester.tap(elevatedButton);
        await tester.pumpAndSettle();
        
        // Verify the event was logged (visible in the event log)
        expect(find.textContaining('ElevatedButton clicked'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Click ElevatedButton: $e');
        rethrow;
      }
    });

    testWidgets('Click event schema validation - FilledButton', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        final filledButton = find.byKey(const ValueKey('filled_btn'));
        expect(filledButton, findsOneWidget);
        
        await tester.tap(filledButton);
        await tester.pumpAndSettle();
        
        expect(find.textContaining('FilledButton clicked'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Click FilledButton: $e');
        rethrow;
      }
    });

    testWidgets('Click event schema validation - OutlinedButton', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        final outlinedButton = find.byKey(const ValueKey('outlined_btn'));
        expect(outlinedButton, findsOneWidget);
        
        await tester.tap(outlinedButton);
        await tester.pumpAndSettle();
        
        expect(find.textContaining('OutlinedButton clicked'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Click OutlinedButton: $e');
        rethrow;
      }
    });

    testWidgets('Click event schema validation - TextButton', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        final textButton = find.byKey(const ValueKey('text_btn'));
        expect(textButton, findsOneWidget);
        
        await tester.tap(textButton);
        await tester.pumpAndSettle();
        
        expect(find.textContaining('TextButton clicked'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Click TextButton: $e');
        rethrow;
      }
    });

    testWidgets('Click event schema validation - IconButton', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        final iconButton = find.byKey(const ValueKey('icon_btn_favorite'));
        expect(iconButton, findsOneWidget);
        
        await tester.tap(iconButton);
        await tester.pumpAndSettle();
        
        expect(find.textContaining('Favorite icon clicked'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Click IconButton: $e');
        rethrow;
      }
    });

    testWidgets('Click event schema validation - Card InkWell', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        final card = find.byKey(const ValueKey('interactive_card'));
        expect(card, findsOneWidget);
        
        await tester.tap(card);
        await tester.pumpAndSettle();
        
        expect(find.textContaining('Card tapped'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Click Card: $e');
        rethrow;
      }
    });

    testWidgets('Click event schema validation - Alert Dialog', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        final alertButton = find.byKey(const ValueKey('alert_btn'));
        expect(alertButton, findsOneWidget);
        
        await tester.tap(alertButton);
        await tester.pumpAndSettle();
        
        // Verify dialog is shown
        expect(find.text('Alert'), findsOneWidget);
        expect(find.text('This is a simple alert dialog.'), findsOneWidget);
        
        // Tap OK button in dialog
        final okButton = find.text('OK');
        expect(okButton, findsOneWidget);
        
        await tester.tap(okButton);
        await tester.pumpAndSettle();
        
        // Verify dialog dismissed event was logged
        expect(find.textContaining('Alert dismissed'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Alert Dialog: $e');
        rethrow;
      }
    });

    testWidgets('Scroll event - horizontal scroll', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        final horizontalList = find.byKey(const ValueKey('horizontal_list'));
        expect(horizontalList, findsOneWidget);
        
        // Items are 100px wide, so Item 5 should not be fully visible initially
        // (screen width ~393px shows about 3-4 items)
        final item5Finder = find.text('Item 5');
        final item5VisibleBefore = item5Finder.evaluate().isNotEmpty;
        
        // Perform a horizontal drag (scroll left to reveal more items)
        await tester.drag(horizontalList, const Offset(-300, 0));
        await tester.pumpAndSettle();
        
        // After scrolling, Item 5 should be visible
        expect(item5Finder, findsOneWidget,
          reason: 'Item 5 should be visible after scrolling left');
        
        // If Item 5 was already visible, verify Item 1 is no longer visible (scrolled off)
        if (item5VisibleBefore) {
          expect(find.text('Item 1'), findsNothing,
            reason: 'Item 1 should have scrolled out of view');
        }
        
      } catch (e) {
        failedTests.add('Horizontal Scroll: $e');
        rethrow;
      }
    });

    testWidgets('Swipe event - Dismissible widget', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        // First ensure the dismissible is visible by scrolling down
        final scrollView = find.byType(SingleChildScrollView);
        await tester.drag(scrollView, const Offset(0, -200));
        await tester.pumpAndSettle();
        
        final dismissible = find.byKey(const ValueKey('dismissible_item'));
        
        // Ensure dismissible widget is found - fail explicitly if not
        expect(dismissible, findsOneWidget, 
          reason: 'Dismissible widget should be visible after scrolling');
        
        // Perform a swipe right
        await tester.drag(dismissible, const Offset(300, 0));
        await tester.pumpAndSettle();
        
        // Verify item was swiped (event logged or item gone)
        expect(find.textContaining('swiped'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Swipe Dismissible: $e');
        rethrow;
      }
    });

    testWidgets('Manual interaction reporting', (WidgetTester tester) async {
      try {
        await _navigateToInteractionDemo(tester);
        
        // Scroll down to find manual report button
        final scrollView = find.byType(SingleChildScrollView);
        await tester.drag(scrollView, const Offset(0, -300));
        await tester.pumpAndSettle();
        
        final manualReportBtn = find.byKey(const ValueKey('manual_report_btn'));
        
        // Ensure manual report button is found - fail explicitly if not
        expect(manualReportBtn, findsOneWidget,
          reason: 'Manual report button should be visible after scrolling');
        
        await tester.tap(manualReportBtn);
        await tester.pumpAndSettle();
        
        // Verify manual interaction was reported
        expect(find.textContaining('Manual interaction reported'), findsOneWidget);
        
      } catch (e) {
        failedTests.add('Manual Interaction Report: $e');
        rethrow;
      }
    });

    tearDownAll(() async {
      // Validate interaction events against schema validator
      final validationResult = await validateSchemaForSession(sessionId);
      
      if (!validationResult.success) {
        failedTests.addAll(validationResult.errors);
      } else {
        debugPrint('Found ${validationResult.interactionEventCount} user interaction events');
      }

      if (failedTests.isNotEmpty) {
        printValidationErrors(failedTests, 'INTERACTION TRACKING TEST FAILURES');
        
        throw Exception(
          'Test failures detected:\n${failedTests.join('\n')}',
        );
      }
    });
  });
}

/// Scrolls to make the target visible and returns true if successful
Future<bool> _scrollToTargetVisible(
  WidgetTester tester,
  Finder scrollable,
  Finder target,
) async {
  for (int i = 0; i < _maxScrollAttempts; i++) {
    await tester.drag(scrollable, const Offset(0, -_scrollDelta));
    await tester.pumpAndSettle();
    
    if (_isFinderVisible(tester, target)) {
      return true;
    }
  }
  return false;
}

/// Gets the screen height dynamically from the tester
double _getScreenHeight(WidgetTester tester) {
  try {
    return tester.view.physicalSize.height / tester.view.devicePixelRatio;
  } catch (e) {
    debugPrint('Warning: Could not get screen height, using fallback 800.0');
    return 800.0;
  }
}

/// Checks if a finder's element is visible in the viewport
bool _isFinderVisible(WidgetTester tester, Finder finder) {
  final elements = finder.evaluate();
  if (elements.isEmpty) return false;
  
  final renderBox = elements.first.renderObject as RenderBox?;
  if (renderBox == null || !renderBox.hasSize) return false;
  
  final position = renderBox.localToGlobal(Offset.zero);
  final screenHeight = _getScreenHeight(tester);
  
  return position.dy > 0 && position.dy < screenHeight - 50;
}

Future<void> _navigateToInteractionDemo(WidgetTester tester) async {
  // Check if app widget tree exists - each testWidgets starts fresh
  // The SDK session is preserved, but the widget tree needs rebuilding
  final elevatedBtnFinder = find.byKey(const ValueKey('elevated_btn'));
  final listFinder = find.byKey(const Key('sdk-options-list'));
  
  final onDemoPage = elevatedBtnFinder.evaluate().isNotEmpty;
  final onMainPage = listFinder.evaluate().isNotEmpty;
  
  if (!onDemoPage && !onMainPage) {
    // Widget tree doesn't exist - rebuild the app
    await tester.pumpWidget(
      const MaterialApp(
        home: app.MyApp(),
      ),
    );
    
    try {
      await tester.pumpAndSettle(const Duration(seconds: 3));
    } catch (e) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
    }
    
    // Wait for session to be ready
    await waitForElement(
      tester,
      find.byKey(const Key('session-id')),
      timeout: const Duration(seconds: 10),
    );
  }
  
  // Re-check if we're on the demo page after potential rebuild
  if (elevatedBtnFinder.evaluate().isNotEmpty) {
    return;
  }

  // Navigate to Interaction Demo page - it's at the very bottom of the list
  final interactionDemoText = find.text('Interaction Tracking Demo');
  
  // Scroll down until the button is visible
  await _scrollToTargetVisible(tester, listFinder, interactionDemoText);
  
  // Tap the card containing the text
  await tester.tap(interactionDemoText);
  await tester.pumpAndSettle(const Duration(seconds: 2));
  
  // Wait for the page to fully load
  await waitForElement(
    tester,
    find.byKey(const ValueKey('elevated_btn')),
    timeout: const Duration(seconds: 10),
  );
}

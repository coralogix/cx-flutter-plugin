import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';

import '../lib/main.dart' as app;

/// Detects if running in CI environment
bool isCI() {
  return Platform.environment.containsKey('CI') ||
      Platform.environment.containsKey('GITHUB_ACTIONS') ||
      Platform.environment.containsKey('GITLAB_CI') ||
      Platform.environment.containsKey('JENKINS') ||
      Platform.environment.containsKey('CIRCLECI') ||
      Platform.environment.containsKey('CONTINUOUS_INTEGRATION');
}

/// Gets timeout duration based on CI environment
Duration getTimeout({Duration? defaultTimeout}) {
  final baseTimeout = defaultTimeout ?? const Duration(seconds: 10);
  return isCI() ? baseTimeout * 3 : baseTimeout;
}

/// Gets polling interval based on CI environment
Duration getPollInterval() {
  return isCI() ? const Duration(milliseconds: 500) : const Duration(milliseconds: 200);
}

/// Waits for a condition to be true, polling at intervals until timeout
Future<void> waitForCondition(
  WidgetTester tester,
  bool Function() conditionFn, {
  Duration? timeout,
  Duration? interval,
  String? errorMessage,
}) async {
  final effectiveTimeout = getTimeout(defaultTimeout: timeout ?? const Duration(seconds: 10));
  final effectiveInterval = interval ?? getPollInterval();
  final startTime = DateTime.now();
  final errorMsg = errorMessage ?? 'Condition not met within timeout';

  while (DateTime.now().difference(startTime) < effectiveTimeout) {
    await tester.pump(effectiveInterval);
    if (conditionFn()) {
      return;
    }
  }

  throw TimeoutException(
    '$errorMsg (timeout: ${effectiveTimeout.inSeconds}s)',
  );
}

/// Waits for an element to appear in the widget tree
Future<void> waitForElement(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration pollInterval = const Duration(milliseconds: 100),
}) async {
  final effectiveTimeout = getTimeout(defaultTimeout: timeout);
  final effectivePollInterval = pollInterval;
  final end = DateTime.now().add(effectiveTimeout);

  while (DateTime.now().isBefore(end)) {
    await tester.pump(effectivePollInterval);

    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TimeoutException(
    'Timed out waiting for element: $finder',
  );
}


/// Waits for the SDK options list to be visible
Future<void> waitForListVisible(
  WidgetTester tester, {
  Duration? timeout,
}) async {
  final listFinder = find.byKey(const Key('sdk-options-list'));
  return waitForElement(
    tester,
    listFinder,
    timeout: timeout ?? const Duration(seconds: 10),
  );
}

/// Checks if an element is actually visible in the viewport
bool _isElementVisibleInViewport(WidgetTester tester, Element element) {
  final RenderBox? renderBox = element.renderObject as RenderBox?;
  if (renderBox == null || !renderBox.hasSize) {
    return false;
  }
  
  try {
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    // Get screen size - try multiple methods
    Size screenSize;
    try {
      screenSize = tester.getSize(find.byType(MaterialApp).first);
    } catch (e) {
      try {
        screenSize = tester.binding.window.physicalSize / tester.binding.window.devicePixelRatio;
      } catch (e2) {
        // Fallback: assume element is visible if we can't determine screen size
        return true;
      }
    }
    
    // Check if element is within screen bounds (with some tolerance)
    const tolerance = 50.0; // Allow some pixels outside viewport
    return position.dx >= -tolerance && 
           position.dy >= -tolerance && 
           position.dx + size.width <= screenSize.width + tolerance &&
           position.dy + size.height <= screenSize.height + tolerance;
  } catch (e) {
    // If we can't determine visibility, assume it's visible
    return true;
  }
}

/// Scrolls to find an element within a scrollable list
Future<bool> scrollToElement(
  WidgetTester tester,
  String testId, {
  int maxAttempts = 10,
}) async {
  final listFinder = find.byKey(const Key('sdk-options-list'));
  final targetFinder = find.byKey(Key(testId));

  // Check if element exists and is visible in viewport
  final elementMatches = targetFinder.evaluate();
  if (elementMatches.isNotEmpty) {
    final firstElement = elementMatches.first;
    if (_isElementVisibleInViewport(tester, firstElement)) {
      return true;
    }
  }

  final scrollAmount = isCI() ? 500.0 : 300.0;
  final scrollDuration = isCI() ? const Duration(milliseconds: 400) : const Duration(milliseconds: 200);

  // Get screen size for reference (with error handling)
  Size screenSize;
  try {
    screenSize = tester.getSize(find.byType(MaterialApp).first);
  } catch (e) {
    try {
      screenSize = tester.binding.window.physicalSize / tester.binding.window.devicePixelRatio;
    } catch (e2) {
      // Fallback: use a default size
      screenSize = const Size(400, 800);
    }
  }
  
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    // Check current element position to determine scroll direction
    final currentMatches = targetFinder.evaluate();
    if (currentMatches.isNotEmpty) {
      final firstElement = currentMatches.first;
      final RenderBox? renderBox = firstElement.renderObject as RenderBox?;
      
      if (renderBox != null && renderBox.hasSize) {
        try {
          final position = renderBox.localToGlobal(Offset.zero);
          final elementCenterY = position.dy + renderBox.size.height / 2;
          final screenCenterY = screenSize.height / 2;
          
          // Determine scroll direction based on element position
          if (elementCenterY < screenCenterY) {
            // Element is above viewport, scroll up
            await tester.drag(listFinder, Offset(0, scrollAmount));
          } else {
            // Element is below viewport, scroll down
            await tester.drag(listFinder, Offset(0, -scrollAmount));
          }
        } catch (e) {
          // If we can't determine position, try scrolling down
          await tester.drag(listFinder, Offset(0, -scrollAmount));
        }
      } else {
        // Element exists but not renderable, try scrolling down
        await tester.drag(listFinder, Offset(0, -scrollAmount));
      }
    } else {
      // Element not found, try scrolling down
      await tester.drag(listFinder, Offset(0, -scrollAmount));
    }
    
    // Wait for scroll to complete
    try {
      await tester.pumpAndSettle(scrollDuration);
    } catch (e) {
      await tester.pump();
      await tester.pump(scrollDuration);
    }

    // Check if element is now visible in viewport
    final updatedMatches = targetFinder.evaluate();
    if (updatedMatches.isNotEmpty) {
      final firstElement = updatedMatches.first;
      if (_isElementVisibleInViewport(tester, firstElement)) {
        return true;
      }
    }
  }

  return false;
}

/// Clicks on an element, handles dialogs, and waits for UI to stabilize
Future<void> clickOnElement(
  WidgetTester tester,
  String testId, {
  bool expectDialog = false,
}) async {
  final elementFinder = find.byKey(Key(testId));
  
  // Wait for element to exist in the widget tree using waitForElement
  await waitForElement(
    tester,
    elementFinder,
    timeout: const Duration(seconds: 10),
  );

  // Try to scroll to the element (this handles the "Too many elements" case)
  final scrolled = await scrollToElement(tester, testId);
  if (!scrolled) {
    // Even if scrolling reports failure, element might still be accessible
    // Continue to try tapping
  }

  // Get the first matching element if multiple exist
  final elementMatches = elementFinder.evaluate();
  if (elementMatches.isEmpty) {
    throw Exception('Element $testId not found in widget tree');
  }
  
  // Use the first matching element
  final firstElement = elementMatches.first;
  final RenderBox? renderBox = firstElement.renderObject as RenderBox?;
  
  if (renderBox == null || !renderBox.hasSize) {
    throw Exception('Element $testId is not renderable or has no size');
  }

  // Get the center position of the element
  final center = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
  
  // Tap at the center of the element
  await tester.tapAt(center);
  await tester.pump();

  // Wait for animations to settle
  try {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  } catch (e) {
    // If pumpAndSettle times out, just pump a few times
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  // Close any dialogs that might have appeared
  await closeAnyDialogs(tester);

  // Wait for list to be visible again (UI stable)
  await waitForListVisible(tester, timeout: const Duration(seconds: 5));
}

/// Closes any open dialogs by finding common dialog buttons
Future<void> closeAnyDialogs(WidgetTester tester) async {
  final dialogButtonTexts = ['OK', 'Close', 'Cancel', 'Dismiss', 'Yes', 'No'];

  for (final buttonText in dialogButtonTexts) {
    final buttonFinder = find.text(buttonText);
    if (tester.any(buttonFinder)) {
      try {
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();
        // Wait a bit to ensure dialog is gone
        await tester.pump(const Duration(milliseconds: 300));
        break;
      } catch (e) {
        // Continue trying other buttons
      }
    }
  }

  // Try Android back button if on Android
  try {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('popRoute'),
      ),
      (ByteData? data) {},
    );
    await tester.pumpAndSettle();
  } catch (e) {
    // Ignore if not applicable
  }

  // Verify no dialog is visible
  final dialogFinder = find.byType(AlertDialog);
  if (tester.any(dialogFinder)) {
    // Try tapping outside or using back
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
  }
}

/// Prepares the app before each test: rebuilds if needed, brings to foreground, closes dialogs, scrolls to top
Future<void> prepareAppForTest(WidgetTester tester) async {
  // Check if app widget tree exists - if not, rebuild it
  final listFinder = find.byKey(const Key('sdk-options-list'));
  final appExists = listFinder.evaluate().isNotEmpty;
  
  if (!appExists) {
    // Rebuild the app widget tree
    await tester.pumpWidget(
      const MaterialApp(
        home: app.MyApp(),
      ),
    );
  
    try {
      await tester.pumpAndSettle(const Duration(seconds: 5));
    } catch (e) {
      // If pumpAndSettle times out, just pump a few more times
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
    }
    
    // Wait for session ID element to appear (it loads asynchronously)
    final sessionIdFinder = find.byKey(const Key('session-id'));
    await waitForElement(
      tester,
      sessionIdFinder,
      timeout: const Duration(seconds: 5),
    );
    
    // Wait a bit more for session ID to actually load (not just "Loading...")
    await tester.pump(const Duration(milliseconds: 1000));
  } else {
    // App already exists, just pump to ensure it's active
    await tester.pumpAndSettle();
  }

  // Close any open dialogs
  await closeAnyDialogs(tester);

  // Wait for list to be visible using waitForElement
  await waitForElement(
    tester,
    listFinder,
    timeout: const Duration(seconds: 5),
  );

  // Scroll to top
  if (listFinder.evaluate().isNotEmpty) {
    // Scroll up multiple times to ensure we're at the top
    for (int i = 0; i < 5; i++) {
      await tester.drag(listFinder, Offset(0, 1000));
      try {
        await tester.pumpAndSettle();
      } catch (e) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
  }
}

/// Finds a widget by key (helper for string-based key lookup)
Finder findKey(Key key) {
  return find.byKey(key);
}

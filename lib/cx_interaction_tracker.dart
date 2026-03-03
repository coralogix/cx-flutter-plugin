import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter/rendering.dart' hide ScrollDirection;
import 'package:flutter/widgets.dart';

import 'cx_flutter_plugin.dart';
import 'cx_instrumentation_type.dart';
import 'cx_interaction_types.dart';

/// Automatic user interaction tracker that hooks into Flutter's gesture system.
/// 
/// This tracker automatically captures taps, scrolls, and swipes without 
/// requiring any wrapper widget. It's initialized automatically when the SDK
/// starts with `userActions` instrumentation enabled.
class CxInteractionTracker {
  static CxInteractionTracker? _instance;
  static bool _isInitialized = false;

  // Configuration
  final double scrollThreshold;
  final double swipeVelocityThreshold;
  final Duration scrollThrottleDuration;
  final bool debug;

  // State tracking
  final Map<int, _PointerState> _pointerStates = {};
  Timer? _scrollThrottleTimer;

  CxInteractionTracker._({
    this.scrollThreshold = 50.0,
    this.swipeVelocityThreshold = 300.0,
    this.scrollThrottleDuration = const Duration(milliseconds: 250),
    this.debug = false,
  });

  /// Initialize automatic interaction tracking.
  /// Called automatically by CxFlutterPlugin.initSdk when userActions is enabled.
  static void initialize({
    double scrollThreshold = 50.0,
    double swipeVelocityThreshold = 300.0,
    Duration scrollThrottleDuration = const Duration(milliseconds: 250),
    bool debug = false,
  }) {
    if (_isInitialized) return;

    _instance = CxInteractionTracker._(
      scrollThreshold: scrollThreshold,
      swipeVelocityThreshold: swipeVelocityThreshold,
      scrollThrottleDuration: scrollThrottleDuration,
      debug: debug,
    );

    _instance!._startListening();
    _isInitialized = true;
    
    if (debug) {
      debugPrint('[CxInteractionTracker] Initialized');
    }
  }

  /// Shutdown the automatic interaction tracker.
  static void shutdown() {
    _instance?._stopListening();
    _instance = null;
    _isInitialized = false;
  }

  static bool get isInitialized => _isInitialized;

  void _log(String message) {
    if (debug) {
      debugPrint('[CxInteractionTracker] $message');
    }
  }

  bool get _isUserActionsEnabled {
    final options = CxFlutterPlugin.globalOptions;
    if (options == null) return false;
    final instrumentations = options.instrumentations;
    if (instrumentations == null) return false;
    return instrumentations[CXInstrumentationType.userActions.value] == true;
  }

  void _startListening() {
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
    _log('Started listening to pointer events');
  }

  void _stopListening() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handlePointerEvent);
    _scrollThrottleTimer?.cancel();
    _pointerStates.clear();
    _log('Stopped listening to pointer events');
  }

  void _handlePointerEvent(PointerEvent event) {
    if (!_isUserActionsEnabled) return;

    if (event is PointerDownEvent) {
      _handlePointerDown(event);
    } else if (event is PointerMoveEvent) {
      _handlePointerMove(event);
    } else if (event is PointerUpEvent) {
      _handlePointerUp(event);
    } else if (event is PointerCancelEvent) {
      _handlePointerCancel(event);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointerStates[event.pointer] = _PointerState(
      startPosition: event.position,
      startTime: event.timeStamp,
      lastPosition: event.position,
      lastTime: event.timeStamp,
    );
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final state = _pointerStates[event.pointer];
    if (state == null) return;

    state.lastPosition = event.position;
    state.lastTime = event.timeStamp;
    state.hasMoved = true;

    final delta = event.position - state.startPosition;
    final direction = _getScrollDirection(delta);

    if (direction != null && !state.scrollReported) {
      state.scrollDirection = direction;
      
      // Throttle scroll events
      if (_scrollThrottleTimer == null || !_scrollThrottleTimer!.isActive) {
        final capturedDirection = direction;
        final capturedPosition = event.position;

        _scrollThrottleTimer = Timer(scrollThrottleDuration, () {
          _reportInteraction(CxInteractionData(
            eventName: InteractionEventName.scroll,
            targetElement: 'Screen',
            scrollDirection: capturedDirection,
            attributes: {
              'x': capturedPosition.dx,
              'y': capturedPosition.dy,
            },
          ));
        });
        
        state.scrollReported = true;
      }
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    final state = _pointerStates.remove(event.pointer);
    if (state == null) return;

    final totalDelta = event.position - state.startPosition;
    final duration = event.timeStamp - state.startTime;
    final velocity = duration.inMilliseconds > 0 
        ? totalDelta / (duration.inMilliseconds / 1000.0)
        : Offset.zero;
    final speed = velocity.distance;

    // Determine event type based on movement
    if (!state.hasMoved || totalDelta.distance < 10) {
      // It's a tap/click - extract widget info at tap position
      final widgetInfo = _extractWidgetInfo(event.position);
      
      _reportInteraction(CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: widgetInfo.targetElement,
        elementClasses: widgetInfo.widgetClassName,
        targetElementInnerText: widgetInfo.text,
        attributes: {
          'x': event.position.dx,
          'y': event.position.dy,
          if (widgetInfo.accessibilityLabel != null) 
            'accessibility_label': widgetInfo.accessibilityLabel,
        },
      ));
    } else if (speed >= swipeVelocityThreshold) {
      // It's a swipe
      final direction = _getSwipeDirection(velocity);
      if (direction != null) {
        _reportInteraction(CxInteractionData(
          eventName: InteractionEventName.swipe,
          targetElement: 'Screen',
          scrollDirection: direction,
          attributes: {
            'x': event.position.dx,
            'y': event.position.dy,
          },
        ));
      }
    }
    // Slow drags without swipe velocity are just scrolls (already reported)
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _pointerStates.remove(event.pointer);
  }

  ScrollDirection? _getScrollDirection(Offset delta) {
    final absDx = delta.dx.abs();
    final absDy = delta.dy.abs();
    
    if (absDy < scrollThreshold && absDx < scrollThreshold) return null;
    
    if (absDy > absDx) {
      return delta.dy > 0 ? ScrollDirection.down : ScrollDirection.up;
    } else {
      return delta.dx > 0 ? ScrollDirection.right : ScrollDirection.left;
    }
  }

  ScrollDirection? _getSwipeDirection(Offset velocity) {
    if (velocity.dy.abs() > velocity.dx.abs()) {
      return velocity.dy > 0 ? ScrollDirection.down : ScrollDirection.up;
    } else {
      return velocity.dx > 0 ? ScrollDirection.right : ScrollDirection.left;
    }
  }

  void _reportInteraction(CxInteractionData data) {
    _log('Reporting: $data');
    CxFlutterPlugin.setUserInteraction(data.toMap());
  }

  /// Extracts information about the widget at the given position.
  /// Returns targetElement with priority: text > accessibility label > widget class name
  _WidgetInfo _extractWidgetInfo(Offset position) {
    String? text;
    String? accessibilityLabel;
    String widgetClassName = 'Unknown';
    
    try {
      final binding = WidgetsBinding.instance;
      final renderView = binding.renderViews.firstOrNull;
      if (renderView == null) {
        return _WidgetInfo(targetElement: 'Screen');
      }

      // Perform hit test to find render objects at position
      final hitTestResult = HitTestResult();
      renderView.hitTest(hitTestResult, position: position);

      // Walk up the element tree from the hit target
      for (final entry in hitTestResult.path) {
        final target = entry.target;
        if (target is RenderObject) {
          // Find the element that owns this render object
          target.debugDescribeChildren();
          
          // Try to get element from debug owner
          final debugOwner = target.debugCreator;
          if (debugOwner is DebugCreator) {
            final element = debugOwner.element;
            final widget = element.widget;
            
            // Update widget class name (we want the most specific one)
            widgetClassName = widget.runtimeType.toString();
            
            // Try to extract text
            text ??= _extractTextFromWidget(widget);
            
            // Try to extract accessibility label
            accessibilityLabel ??= _extractAccessibilityLabel(widget, element);
            
            // If we found text, we can stop
            if (text != null) break;
          }
        }
      }
    } catch (e) {
      _log('Error extracting widget info: $e');
    }

    // Priority: text > accessibility label > widget class name
    final targetElement = text ?? accessibilityLabel ?? widgetClassName;
    
    return _WidgetInfo(
      targetElement: targetElement,
      text: text,
      accessibilityLabel: accessibilityLabel,
      widgetClassName: widgetClassName,
    );
  }

  /// Extracts text content from a widget if it's a Text or RichText widget.
  String? _extractTextFromWidget(Widget widget) {
    if (widget is Text) {
      return widget.data ?? widget.textSpan?.toPlainText();
    } else if (widget is RichText) {
      return widget.text.toPlainText();
    }
    return null;
  }

  /// Extracts accessibility label from Semantics widget or tooltip.
  String? _extractAccessibilityLabel(Widget widget, Element element) {
    if (widget is Semantics) {
      return widget.properties.label ?? widget.properties.hint;
    }
    if (widget is Tooltip) {
      return widget.message;
    }
    
    // Check if widget has a key that could be used as identifier
    if (widget.key is ValueKey) {
      final valueKey = widget.key as ValueKey;
      final value = valueKey.value;
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    
    return null;
  }
}

class _WidgetInfo {
  final String targetElement;
  final String? text;
  final String? accessibilityLabel;
  final String widgetClassName;

  _WidgetInfo({
    required this.targetElement,
    this.text,
    this.accessibilityLabel,
    this.widgetClassName = 'Unknown',
  });
}

class _PointerState {
  final Offset startPosition;
  final Duration startTime;
  Offset lastPosition;
  Duration lastTime;
  bool hasMoved = false;
  bool scrollReported = false;
  ScrollDirection? scrollDirection;

  _PointerState({
    required this.startPosition,
    required this.startTime,
    required this.lastPosition,
    required this.lastTime,
  });
}

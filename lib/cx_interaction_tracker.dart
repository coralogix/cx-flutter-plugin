import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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

        _scrollThrottleTimer = Timer(scrollThrottleDuration, () {
          _reportInteraction(CxInteractionData(
            eventName: InteractionEventName.scroll,
            targetElement: 'Screen',
            scrollDirection: capturedDirection,
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
    _log('Reporting: ${data.toMap()}');
    CxFlutterPlugin.setUserInteraction(data.toMap());
  }

  /// Extracts information about the widget at the given position.
  /// Uses hit testing to find only VISIBLE elements at the tap position.
  _WidgetInfo _extractWidgetInfo(Offset position) {
    try {
      // Use hit testing to get only visible elements
      final renderView = WidgetsBinding.instance.renderViews.firstOrNull;
      if (renderView == null) {
        return _WidgetInfo(targetElement: 'Screen');
      }

      final hitTestResult = HitTestResult();
      renderView.hitTest(hitTestResult, position: position);

      // Collect widgets from hit test path (deepest first)
      String? textContent;
      String? semanticsLabel;
      String? elementClassName;
      
      for (final entry in hitTestResult.path) {
        final target = entry.target;
        if (target is! RenderObject) continue;
        
        final debugCreator = target.debugCreator;
        if (debugCreator is! DebugCreator) continue;
        
        final element = debugCreator.element;
        final widget = element.widget;
        final className = widget.runtimeType.toString();
        
        // Skip internal widgets
        if (className.startsWith('_')) continue;
        
        // 1. Find the first Text content (deepest text near tap)
        if (textContent == null) {
          if (widget is Text) {
            textContent = _nonEmpty(widget.data ?? widget.textSpan?.toPlainText());
          } else if (widget is RichText) {
            textContent = _nonEmpty(widget.text.toPlainText());
          }
        }
        
        // 2. Find semantics label
        if (semanticsLabel == null) {
          if (widget is Semantics) {
            semanticsLabel = _nonEmpty(widget.properties.label);
          } else if (widget is IconButton) {
            semanticsLabel = _nonEmpty(widget.tooltip);
          } else if (widget is Tooltip) {
            semanticsLabel = _nonEmpty(widget.message);
          }
        }
        
        // 3. Find the first meaningful widget class (not Text/Icon/layout widgets)
        if (elementClassName == null && _isDetectingElement(className)) {
          elementClassName = className;
        }
      }
      
      // Use semantics label as fallback for text
      final innerText = textContent ?? semanticsLabel;
      final targetElement = elementClassName ?? 'Screen';
      
      return _WidgetInfo(
        targetElement: targetElement,
        text: innerText,
        accessibilityLabel: semanticsLabel,
        widgetClassName: targetElement,
      );
    } catch (e) {
      _log('Error extracting widget info: $e');
    }

    return _WidgetInfo(targetElement: 'Screen');
  }
  
  /// Returns true if this is a meaningful detecting element (not just layout/text)
  bool _isDetectingElement(String className) {
    // Interactive elements we want to detect
    const detectingElements = {
      'Button', 'ElevatedButton', 'TextButton', 'OutlinedButton', 'FilledButton',
      'IconButton', 'FloatingActionButton', 'PopupMenuButton', 'DropdownButton',
      'Card', 'ListTile', 'Tab', 'Chip', 'Dismissible',
      'Switch', 'Checkbox', 'Radio', 'Slider',
      'BottomNavigationBar', 'NavigationRail', 'TabBar',
      'InkWell', 'GestureDetector', 'InkResponse',
      'Container', 'DecoratedBox', 'Material',
    };
    return detectingElements.contains(className);
  }

  /// Returns null if string is null or empty/whitespace.
  String? _nonEmpty(String? s) => (s != null && s.trim().isNotEmpty) ? s : null;
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

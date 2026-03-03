import 'dart:async';

import 'package:flutter/material.dart';

import 'cx_flutter_plugin.dart';
import 'cx_instrumentation_type.dart';
import 'cx_interaction_types.dart';

/// Callback to resolve a custom target name for an element.
/// Return null to use the default (widget class name).
typedef ResolveTargetName = String? Function(Element element);

/// Callback to determine if inner text should be sent (PII consideration).
typedef ShouldSendText = bool Function(Element element);

/// A widget that tracks user interactions and reports them to Coralogix.
///
/// Wrap your app or specific screens with this widget to enable
/// click, scroll, and swipe tracking.
///
/// Tracking is automatically enabled when `userActions` instrumentation
/// is set to `true` in [CXExporterOptions.instrumentations].
///
/// ```dart
/// CxInteractionTracker(
///   child: MyApp(),
/// )
/// ```
class CxInteractionTracker extends StatefulWidget {
  /// The child widget tree to track interactions on.
  final Widget child;

  /// Minimum scroll delta (in pixels) to report a scroll event.
  final double scrollThreshold;

  /// Minimum swipe velocity to distinguish swipe from scroll.
  final double swipeVelocityThreshold;

  /// Throttle duration for scroll events.
  final Duration scrollThrottleDuration;

  /// Custom callback to resolve target names.
  final ResolveTargetName? resolveTargetName;

  /// Callback to determine if inner text should be sent.
  final ShouldSendText? shouldSendText;

  /// Enable debug logging.
  final bool debug;

  const CxInteractionTracker({
    super.key,
    required this.child,
    this.scrollThreshold = 50.0,
    this.swipeVelocityThreshold = 300.0,
    this.scrollThrottleDuration = const Duration(milliseconds: 250),
    this.resolveTargetName,
    this.shouldSendText,
    this.debug = false,
  });

  @override
  State<CxInteractionTracker> createState() => _CxInteractionTrackerState();
}

class _CxInteractionTrackerState extends State<CxInteractionTracker> {
  Offset? _panStartPosition;
  DateTime? _panStartTime;
  Timer? _scrollThrottleTimer;
  Offset? _lastScrollPosition;
  ScrollDirection? _accumulatedScrollDirection;

  bool get _isUserActionsEnabled {
    final options = CxFlutterPlugin.globalOptions;
    if (options == null) return false;
    
    final instrumentations = options.instrumentations;
    if (instrumentations == null) return false;
    
    return instrumentations[CXInstrumentationType.userActions.value] == true;
  }

  @override
  void dispose() {
    _scrollThrottleTimer?.cancel();
    super.dispose();
  }

  void _log(String message) {
    if (widget.debug) {
      debugPrint('[CxInteractionTracker] $message');
    }
  }

  /// Extracts widget information from the render tree at the given position.
  _WidgetInfo? _extractWidgetInfo(Offset globalPosition) {
    final RenderObject? rootRender = context.findRenderObject();
    if (rootRender == null) return null;

    Element? targetElement;
    String? elementClasses;
    String? elementId;
    String? innerText;

    final shouldSendTextCallback = widget.shouldSendText;

    void visitor(Element element) {
      final RenderObject? renderObject = element.renderObject;
      if (renderObject is RenderBox && renderObject.hasSize) {
        final Offset localPosition = renderObject.globalToLocal(globalPosition);
        if (renderObject.paintBounds.contains(localPosition)) {
          targetElement = element;

          final visitedWidget = element.widget;
          elementClasses = visitedWidget.runtimeType.toString();

          // Try to extract semantic label or key
          if (visitedWidget.key is ValueKey) {
            final key = visitedWidget.key as ValueKey;
            elementId = key.value?.toString();
          }

          // Try to extract text content
          if (visitedWidget is Text) {
            final shouldSend = shouldSendTextCallback?.call(element) ?? true;
            if (shouldSend) {
              innerText = visitedWidget.data ?? visitedWidget.textSpan?.toPlainText();
            }
          } else if (visitedWidget is RichText) {
            final shouldSend = shouldSendTextCallback?.call(element) ?? true;
            if (shouldSend) {
              innerText = visitedWidget.text.toPlainText();
            }
          }

          // Check for Semantics label
          if (visitedWidget is Semantics && visitedWidget.properties.label != null) {
            elementId ??= visitedWidget.properties.label;
          }

          element.visitChildren(visitor);
        }
      }
    }

    context.visitChildElements(visitor);

    if (targetElement == null) return null;

    String targetName = elementClasses ?? 'Unknown';
    if (widget.resolveTargetName != null) {
      final resolved = widget.resolveTargetName!(targetElement!);
      if (resolved != null && resolved.isNotEmpty) {
        targetName = resolved;
      }
    }

    return _WidgetInfo(
      elementClasses: elementClasses,
      elementId: elementId,
      innerText: innerText,
      targetElement: targetName,
    );
  }

  void _reportInteraction(CxInteractionData data) {
    _log('Reporting: $data');
    CxFlutterPlugin.setUserInteraction(data.toMap());
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isUserActionsEnabled) return;

    final widgetInfo = _extractWidgetInfo(details.globalPosition);
    if (widgetInfo == null) return;

    final data = CxInteractionData(
      eventName: InteractionEventName.click,
      elementClasses: widgetInfo.elementClasses,
      elementId: widgetInfo.elementId,
      targetElementInnerText: widgetInfo.innerText,
      targetElement: widgetInfo.targetElement,
      attributes: {
        'x': details.globalPosition.dx,
        'y': details.globalPosition.dy,
      },
    );

    _reportInteraction(data);
  }

  void _handlePanStart(DragStartDetails details) {
    _panStartPosition = details.globalPosition;
    _panStartTime = DateTime.now();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isUserActionsEnabled) return;
    if (_panStartPosition == null) return;

    final delta = details.globalPosition - _panStartPosition!;
    final direction = _getScrollDirection(delta);

    if (direction == null) return;

    _accumulatedScrollDirection = direction;
    _lastScrollPosition = details.globalPosition;

    // Throttle scroll events
    if (_scrollThrottleTimer == null || !_scrollThrottleTimer!.isActive) {
      _scrollThrottleTimer = Timer(widget.scrollThrottleDuration, () {
        if (_accumulatedScrollDirection != null && _lastScrollPosition != null) {
          final widgetInfo = _extractWidgetInfo(_lastScrollPosition!);
          
          final data = CxInteractionData(
            eventName: InteractionEventName.scroll,
            elementClasses: widgetInfo?.elementClasses,
            elementId: widgetInfo?.elementId,
            targetElementInnerText: widgetInfo?.innerText,
            scrollDirection: _accumulatedScrollDirection,
            targetElement: widgetInfo?.targetElement ?? 'ScrollView',
            attributes: {
              'x': _lastScrollPosition!.dx,
              'y': _lastScrollPosition!.dy,
            },
          );

          _reportInteraction(data);
          _accumulatedScrollDirection = null;
        }
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isUserActionsEnabled) return;
    if (_panStartPosition == null || _panStartTime == null) return;

    final velocity = details.velocity.pixelsPerSecond;
    final speed = velocity.distance;

    // Check if this is a swipe (fast gesture)
    if (speed >= widget.swipeVelocityThreshold) {
      final direction = _getSwipeDirection(velocity);
      if (direction != null) {
        final widgetInfo = _lastScrollPosition != null
            ? _extractWidgetInfo(_lastScrollPosition!)
            : null;

        final data = CxInteractionData(
          eventName: InteractionEventName.swipe,
          elementClasses: widgetInfo?.elementClasses,
          elementId: widgetInfo?.elementId,
          targetElementInnerText: widgetInfo?.innerText,
          scrollDirection: direction,
          targetElement: widgetInfo?.targetElement ?? 'SwipeArea',
          attributes: {
            'x': velocity.dx,
            'y': velocity.dy,
          },
        );

        _reportInteraction(data);
      }
    }

    _panStartPosition = null;
    _panStartTime = null;
  }

  ScrollDirection? _getScrollDirection(Offset delta) {
    final threshold = widget.scrollThreshold;
    
    if (delta.dy.abs() > delta.dx.abs()) {
      if (delta.dy > threshold) return ScrollDirection.down;
      if (delta.dy < -threshold) return ScrollDirection.up;
    } else {
      if (delta.dx > threshold) return ScrollDirection.right;
      if (delta.dx < -threshold) return ScrollDirection.left;
    }
    return null;
  }

  ScrollDirection? _getSwipeDirection(Offset velocity) {
    if (velocity.dy.abs() > velocity.dx.abs()) {
      return velocity.dy > 0 ? ScrollDirection.down : ScrollDirection.up;
    } else {
      return velocity.dx > 0 ? ScrollDirection.right : ScrollDirection.left;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (_isUserActionsEnabled) {
          _handleTapDown(TapDownDetails(
            globalPosition: event.position,
            localPosition: event.localPosition,
          ));
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: widget.child,
      ),
    );
  }
}

class _WidgetInfo {
  final String? elementClasses;
  final String? elementId;
  final String? innerText;
  final String targetElement;

  _WidgetInfo({
    this.elementClasses,
    this.elementId,
    this.innerText,
    required this.targetElement,
  });
}

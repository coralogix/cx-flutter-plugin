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
  /// Threshold in pixels - movement less than this is a tap, more is scroll/swipe
  final double tapThreshold;
  final bool debug;

  // State tracking
  final Map<int, _PointerState> _pointerStates = {};

  CxInteractionTracker._({
    this.tapThreshold = 20.0,  // Same as native iOS SDK
    this.debug = false,
  });

  /// Initialize automatic interaction tracking.
  /// Called automatically by CxFlutterPlugin.initSdk when userActions is enabled.
  static void initialize({
    double tapThreshold = 20.0,  // Same as native iOS SDK
    bool debug = false,
  }) {
    if (_isInitialized) return;

    _instance = CxInteractionTracker._(
      tapThreshold: tapThreshold,
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
  }

  void _handlePointerUp(PointerUpEvent event) {
    final state = _pointerStates.remove(event.pointer);
    if (state == null) return;

    final totalDelta = event.position - state.startPosition;
    final dx = totalDelta.dx;
    final dy = totalDelta.dy;
    final displacement = totalDelta.distance;

    // Native iOS SDK approach: movement < 20px = tap, >= 20px = scroll/swipe
    if (displacement < tapThreshold) {
      // It's a tap/click - extract widget info at tap position
      final widgetInfo = _extractWidgetInfo(event.position);
      
      // Only include targetElementInnerText if there's actual visible text
      final innerText = _nonEmpty(widgetInfo.text);
      
      _reportInteraction(CxInteractionData(
        eventName: InteractionEventName.click,
        targetElement: widgetInfo.targetElement,
        elementClasses: widgetInfo.widgetClassName,
        targetElementInnerText: innerText,
        attributes: {
          'x': event.position.dx,
          'y': event.position.dy,
        },
      ));
    } else {
      // It's a scroll or swipe - use displacement-based direction (like native iOS)
      // Native iOS: vertical if abs(dy) >= abs(dx), otherwise horizontal
      final direction = _getDirectionFromDisplacement(dx, dy);
      
      // Check if we're inside a swipe context (PageView, Dismissible, etc.)
      final isSwipeContext = _isSwipeContext(event.position);
      final eventName = isSwipeContext 
          ? InteractionEventName.swipe 
          : InteractionEventName.scroll;
      
      _reportInteraction(CxInteractionData(
        eventName: eventName,
        targetElement: 'Screen',
        scrollDirection: direction,
      ));
    }
  }
  
  /// Get direction from displacement (like native iOS SDK)
  ScrollDirection _getDirectionFromDisplacement(double dx, double dy) {
    if (dy.abs() >= dx.abs()) {
      // Vertical movement
      return dy < 0 ? ScrollDirection.up : ScrollDirection.down;
    } else {
      // Horizontal movement
      return dx < 0 ? ScrollDirection.left : ScrollDirection.right;
    }
  }
  
  /// Check if gesture is in a swipe context (PageView, Dismissible, etc.)
  /// Similar to native iOS isPagingEnabled check
  bool _isSwipeContext(Offset position) {
    try {
      bool foundSwipeWidget = false;
      
      // Use hit testing to find elements at position and check ancestors
      for (final renderView in WidgetsBinding.instance.renderViews) {
        final hitTestResult = HitTestResult();
        renderView.hitTest(hitTestResult, position: position);
        
        for (final entry in hitTestResult.path) {
          final target = entry.target;
          if (target is RenderObject) {
            void checkElement(Element element) {
              if (foundSwipeWidget) return;
              if (element.renderObject == target) {
                // Walk up ancestors to find swipe-related widgets
                element.visitAncestorElements((ancestor) {
                  final name = ancestor.widget.runtimeType.toString();
                  // PageView = paged scrolling (like iOS isPagingEnabled)
                  // Dismissible = swipe to dismiss
                  // TabBarView = swipeable tabs
                  if (name == 'PageView' || 
                      name == 'Dismissible' || 
                      name == 'TabBarView') {
                    foundSwipeWidget = true;
                    return false;
                  }
                  return true;
                });
              }
              element.visitChildElements(checkElement);
            }
            WidgetsBinding.instance.rootElement?.visitChildElements(checkElement);
            if (foundSwipeWidget) return true;
          }
        }
      }
    } catch (e) {
      _log('Error checking swipe context: $e');
    }
    return false;
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    final state = _pointerStates.remove(event.pointer);
    if (state == null) return;
    
    // Native iOS SDK also reports scroll on cancel (when scroll view takes over)
    if (state.hasMoved) {
      final totalDelta = state.lastPosition - state.startPosition;
      final dx = totalDelta.dx;
      final dy = totalDelta.dy;
      final displacement = totalDelta.distance;
      
      if (displacement >= tapThreshold) {
        final direction = _getDirectionFromDisplacement(dx, dy);
        final isSwipeContext = _isSwipeContext(state.lastPosition);
        final eventName = isSwipeContext 
            ? InteractionEventName.swipe 
            : InteractionEventName.scroll;
        
        _reportInteraction(CxInteractionData(
          eventName: eventName,
          targetElement: 'Screen',
          scrollDirection: direction,
        ));
      }
    }
  }

  void _reportInteraction(CxInteractionData data) {
    _log('Reporting: ${data.toMap()}');
    CxFlutterPlugin.setUserInteraction(data.toMap());
  }

  /// Extracts information about the widget at the given position.
  /// Uses hit testing to find visible elements, then walks up the tree.
  _WidgetInfo _extractWidgetInfo(Offset position) {
    try {
      // Use hit testing to get only visible elements
      // Check all render views (dialogs/overlays may be in different views)
      final renderViews = WidgetsBinding.instance.renderViews;
      if (renderViews.isEmpty) {
        return _WidgetInfo(targetElement: 'Screen');
      }

      Element? deepestElement;
      Element? bestInteractiveElement;
      
      // Try each render view - collect ALL hit elements from ALL views
      final allHitElements = <Element>[];
      for (final renderView in renderViews) {
        final hitTestResult = HitTestResult();
        renderView.hitTest(hitTestResult, position: position);

        for (final entry in hitTestResult.path) {
          final target = entry.target;
          if (target is RenderObject) {
            final debugCreator = target.debugCreator;
            if (debugCreator is DebugCreator) {
              allHitElements.add(debugCreator.element);
            }
          }
        }
      }
      
      // Search for interactive elements in ALL hit elements and their ancestors
      // Prefer specific buttons over generic gesture handlers
      Element? genericElementFallback;
      
      for (int i = 0; i < allHitElements.length; i++) {
        final element = allHitElements[i];
        Element? current = element;
        while (current != null) {
          final className = current.widget.runtimeType.toString();
          // Remove leading underscore for checking (private widget classes)
          final cleanName = className.startsWith('_') ? className.substring(1) : className;
          
          final isDetecting = _isDetectingElement(className) || _isDetectingElement(cleanName) || cleanName.contains('Button');
          
          if (isDetecting) {
            if (_isGenericGestureWidget(className)) {
              // Save as fallback, keep looking for better match
              genericElementFallback ??= current;
            } else {
              // Found a specific widget - use it!
              bestInteractiveElement = current;
              break;
            }
          }
          Element? parent;
          current.visitAncestorElements((ancestor) {
            parent = ancestor;
            return false;
          });
          current = parent;
        }
        if (bestInteractiveElement != null) break;
      }
      
      // If we only found barrier widgets (e.g., clicking on dialog button),
      // search the element tree by checking bounds
      if (bestInteractiveElement == null && allHitElements.isNotEmpty) {
        final firstWidget = allHitElements.first.widget;
        if (firstWidget is Listener) {
          bestInteractiveElement = _findDialogContentAtPosition(position);
        }
      }
      
      // Use generic fallback if no specific element found
      bestInteractiveElement ??= genericElementFallback;
      
      deepestElement = bestInteractiveElement ?? allHitElements.firstOrNull;

      if (deepestElement == null) {
        return _WidgetInfo(targetElement: 'Screen');
      }

      // Use the already-found bestInteractiveElement for the class name
      String? elementClassName;
      if (bestInteractiveElement != null) {
        final rawName = bestInteractiveElement.widget.runtimeType.toString();
        // Strip leading underscore for display
        elementClassName = rawName.startsWith('_') ? rawName.substring(1) : rawName;
      }
      
      // Find text content - first check CHILDREN of bestInteractiveElement (for buttons)
      // then fall back to walking UP from deepestElement
      String? textContent;
      String? semanticsLabel;
      
      // Search children of interactive element for text
      if (bestInteractiveElement != null) {
        textContent = _findTextInChildren(bestInteractiveElement);
      }
      
      // If no text found in children, walk UP from deepest element
      if (textContent == null) {
        Element? current = deepestElement;
        while (current != null) {
          final widget = current.widget;
          
          // Find Text content
          if (textContent == null) {
            if (widget is Text) {
              textContent = _nonEmpty(widget.data ?? widget.textSpan?.toPlainText());
            } else if (widget is RichText) {
              textContent = _nonEmpty(widget.text.toPlainText());
            }
          }
          
          // Find semantics/tooltip
          if (semanticsLabel == null) {
            if (widget is Semantics) {
              semanticsLabel = _nonEmpty(widget.properties.label);
            } else if (widget is IconButton) {
              semanticsLabel = _nonEmpty(widget.tooltip);
            } else if (widget is Tooltip) {
              semanticsLabel = _nonEmpty(widget.message);
            }
          }
          
          // Stop if we found text
          if (textContent != null) break;
          
          // Move up to parent
          Element? parent;
          current.visitAncestorElements((ancestor) {
            parent = ancestor;
            return false;
          });
          current = parent;
        }
      }
      
      // Only use actual visible text, not semantics labels
      final innerText = textContent;
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
  
  /// Returns true if this is a meaningful interactive element
  bool _isDetectingElement(String className) {
    // Only truly interactive elements - not layout/styling widgets
    const detectingElements = {
      // Buttons
      'Button', 'ElevatedButton', 'TextButton', 'OutlinedButton', 'FilledButton',
      'IconButton', 'FloatingActionButton', 'PopupMenuButton', 'DropdownButton',
      'ButtonStyleButton', // Base class for Material buttons
      // Tappable widgets
      'Card', 'ListTile', 'Tab', 'Chip', 'Dismissible',
      // Form controls
      'Switch', 'Checkbox', 'Radio', 'Slider',
      // Navigation
      'BottomNavigationBar', 'NavigationRail', 'TabBar',
      // Dialogs
      'AlertDialog', 'Dialog', 'SimpleDialog',
      // Gesture handlers (last resort)
      'InkWell', 'GestureDetector', 'InkResponse',
    };
    
    // Also check if class name ends with "Button" (catches custom buttons)
    if (className.endsWith('Button')) return true;
    
    return detectingElements.contains(className);
  }
  
  /// Returns true if this is a generic gesture widget (used as fallback)
  bool _isGenericGestureWidget(String className) {
    const genericWidgets = {'GestureDetector', 'InkWell', 'InkResponse'};
    return genericWidgets.contains(className);
  }

  /// Returns null if string is null or empty/whitespace.
  /// Returns null if string is null, empty, or contains only icon font glyphs.
  String? _nonEmpty(String? s) {
    if (s == null) return null;
    final trimmed = s.trim();
    if (trimmed.isEmpty) return null;
    // Filter out icon font characters (Private Use Area: U+E000-U+F8FF)
    final hasRealText = !trimmed.codeUnits.every((c) => c >= 0xE000 && c <= 0xF8FF);
    if (!hasRealText) return null;
    return trimmed;
  }
  
  /// Searches the children of an element for Text content.
  /// Filters out icon font characters.
  String? _findTextInChildren(Element element) {
    String? foundText;
    
    void search(Element el) {
      if (foundText != null) return;
      
      final widget = el.widget;
      
      if (widget is Text) {
        foundText = _nonEmpty(widget.data ?? widget.textSpan?.toPlainText());
      } else if (widget is RichText) {
        foundText = _nonEmpty(widget.text.toPlainText());
      }
      
      if (foundText == null) {
        el.visitChildren(search);
      }
    }
    
    element.visitChildren(search);
    return foundText;
  }
  
  /// Tries to find the smallest interactive element at the given position.
  /// Walks the element tree and checks bounds, returning the most specific match.
  Element? _findDialogContentAtPosition(Offset position) {
    try {
      final rootElement = WidgetsBinding.instance.rootElement;
      if (rootElement == null) return null;
      
      Element? bestMatch;
      double bestArea = double.infinity;
      
      void searchElement(Element element) {
        final renderObject = element.renderObject;
        if (renderObject is RenderBox && renderObject.hasSize) {
          try {
            final transform = renderObject.getTransformTo(null);
            final bounds = MatrixUtils.transformRect(
              transform,
              Offset.zero & renderObject.size,
            );
            
            if (bounds.contains(position)) {
              final className = element.widget.runtimeType.toString();
              final cleanName = className.startsWith('_') ? className.substring(1) : className;
              
              // Check if this is an interactive element
              final isInteractive = _isDetectingElement(className) || 
                  _isDetectingElement(cleanName) || 
                  cleanName.contains('Button');
              
              if (isInteractive && !_isGenericGestureWidget(className)) {
                // Prefer smaller (more specific) elements
                final area = bounds.width * bounds.height;
                if (area < bestArea) {
                  bestArea = area;
                  bestMatch = element;
                }
              }
            }
          } catch (_) {
            // Transform might fail for some elements, skip them
          }
        }
        
        // Continue searching children
        element.visitChildren(searchElement);
      }
      
      searchElement(rootElement);
      return bestMatch;
    } catch (e) {
      _log('Error finding element at position: $e');
      return null;
    }
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

  _PointerState({
    required this.startPosition,
    required this.startTime,
    required this.lastPosition,
    required this.lastTime,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/services.dart';

/// Controller to handle keyboard events and delegate to custom or global handlers
class KeyboardController {
  static Function()? onUp;
  static Function()? onDown;
  static Function()? onLeft;
  static Function()? onRight;
  static Function()? onEnter;

  static void up() {
    if (kDebugMode) {
      print('[KeyboardController] Arrow UP pressed');
    }
    // Try custom handler first, then fallback to global scroll
    if (onUp != null) {
      onUp?.call();
    } else {
      GlobalKeyboardScrollHandler.scrollUp();
    }
  }
  
  static void down() {
    if (kDebugMode) {
      print('[KeyboardController] Arrow DOWN pressed');
    }
    // Try custom handler first, then fallback to global scroll
    if (onDown != null) {
      onDown?.call();
    } else {
      GlobalKeyboardScrollHandler.scrollDown();
    }
  }
  
  static void left() {
    if (kDebugMode) {
      print('[KeyboardController] Arrow LEFT pressed');
    }
    // Try custom handler first, then fallback to global scroll
    if (onLeft != null) {
      onLeft?.call();
    } else {
      GlobalKeyboardScrollHandler.scrollLeft();
    }
  }
  
  static void right() {
    if (kDebugMode) {
      print('[KeyboardController] Arrow RIGHT pressed');
    }
    // Try custom handler first, then fallback to global scroll
    if (onRight != null) {
      onRight?.call();
    } else {
      GlobalKeyboardScrollHandler.scrollRight();
    }
  }
  
  static void enter() => onEnter?.call();
}

/// Global keyboard scroll handler that automatically finds and scrolls
/// the nearest scrollable widget in the widget tree.
class GlobalKeyboardScrollHandler {
  static const double _scrollStep = 100.0;
  static BuildContext? _currentRouteContext;
  
  /// Set the current route context (called from NavigatorObserver)
  static void setCurrentRouteContext(BuildContext? context) {
    _currentRouteContext = context;
  }
  
  /// Finds the nearest Scrollable widget and scrolls it up
  static void scrollUp() {
    if (kDebugMode) {
      print('[KeyboardScroll] scrollUp() called');
    }
    _scroll(-_scrollStep);
  }
  
  /// Finds the nearest Scrollable widget and scrolls it down
  static void scrollDown() {
    if (kDebugMode) {
      print('[KeyboardScroll] scrollDown() called');
    }
    _scroll(_scrollStep);
  }
  
  /// Finds the nearest Scrollable widget and scrolls it left
  static void scrollLeft() {
    _scroll(-_scrollStep);
  }
  
  /// Finds the nearest Scrollable widget and scrolls it right
  static void scrollRight() {
    _scroll(_scrollStep);
  }
  
  static void _scroll(double delta) {
    // Try multiple strategies to find the scrollable
    ScrollableState? scrollable;
    BuildContext? contextToUse = _currentRouteContext;
    
    // Strategy 1: Use primary focus context (most reliable for keyboard events)
    final focusManager = WidgetsBinding.instance.focusManager;
    final primaryFocus = focusManager.primaryFocus;
    if (primaryFocus != null) {
      final focusContext = primaryFocus.context;
      if (focusContext != null) {
        contextToUse = focusContext;
        scrollable = Scrollable.maybeOf(focusContext);
        
        // Try PrimaryScrollController from focus context
        try {
          final primaryScrollController = PrimaryScrollController.maybeOf(focusContext);
          if (primaryScrollController != null && primaryScrollController.hasClients) {
            final position = primaryScrollController.position;
            if (position.hasContentDimensions) {
              final newOffset = (position.pixels + delta).clamp(
                0.0,
                position.maxScrollExtent,
              );
              if (newOffset != position.pixels) {
                position.animateTo(
                  newOffset,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                if (kDebugMode) {
                  print('[KeyboardScroll] Scrolled ${delta > 0 ? "down" : "up"} to ${newOffset.toStringAsFixed(1)} using PrimaryScrollController (focus)');
                }
                return;
              }
            }
          }
        } catch (e) {
          // PrimaryScrollController might not be available
        }
      }
    }
    
    // Strategy 2: Try from the stored route context
    if (scrollable == null) {
      contextToUse = _currentRouteContext;
      if (contextToUse != null) {
        scrollable = Scrollable.maybeOf(contextToUse);
      }
    }
    
    // Strategy 3: Try PrimaryScrollController from route context (if not already tried)
    if (scrollable == null) {
      contextToUse = _currentRouteContext;
      if (contextToUse != null) {
        try {
          final primaryScrollController = PrimaryScrollController.maybeOf(contextToUse);
          if (primaryScrollController != null && primaryScrollController.hasClients) {
            final position = primaryScrollController.position;
            if (position.hasContentDimensions) {
              final newOffset = (position.pixels + delta).clamp(
                0.0,
                position.maxScrollExtent,
              );
              if (newOffset != position.pixels) {
                position.animateTo(
                  newOffset,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                if (kDebugMode) {
                  print('[KeyboardScroll] Scrolled ${delta > 0 ? "down" : "up"} to ${newOffset.toStringAsFixed(1)} using PrimaryScrollController (route)');
                }
                return;
              }
            }
          }
        } catch (e) {
          // PrimaryScrollController might not be available
        }
      }
    }
    
    // Strategy 4: Search through ancestor elements (more thorough)
    if (scrollable == null && contextToUse != null) {
      scrollable = _searchAncestorsForScrollable(contextToUse);
    }
    
    // Strategy 5: Try from navigator context
    if (scrollable == null && contextToUse != null) {
      try {
        final navigator = Navigator.of(contextToUse, rootNavigator: true);
        scrollable = Scrollable.maybeOf(navigator.context);
      } catch (e) {
        // Navigator might not be available
      }
    }
    
    // Strategy 6: Try from overlay context
    if (scrollable == null && contextToUse != null) {
      try {
        final navigator = Navigator.of(contextToUse, rootNavigator: true);
        final overlay = navigator.overlay;
        final overlayContext = overlay?.context;
        if (overlayContext != null) {
          scrollable = Scrollable.maybeOf(overlayContext);
        }
      } catch (e) {
        // Overlay might not be available
      }
    }
    
    if (scrollable != null && scrollable.position.hasContentDimensions) {
      try {
        final position = scrollable.position;
        final newOffset = (position.pixels + delta).clamp(
          0.0,
          position.maxScrollExtent,
        );
        
        if (newOffset != position.pixels) {
          position.animateTo(
            newOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          if (kDebugMode) {
            print('[KeyboardScroll] Scrolled ${delta > 0 ? "down" : "up"} to ${newOffset.toStringAsFixed(1)}');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('[KeyboardScroll] Error scrolling: $e');
        }
      }
    } else {
      // Last resort: Try web-specific scrolling
      if (kDebugMode) {
        print('[KeyboardScroll] No scrollable found. Trying web window scroll...');
      }
      _tryWebWindowScroll(delta);
    }
  }
  
  /// Web-specific fallback: scroll the browser window directly
  static void _tryWebWindowScroll(double delta) {
    try {
      // This is a web-specific fallback
      // In Flutter web, we can access the window object
      if (kIsWeb) {
        // Use dart:html for window scrolling (if available)
        // Note: This requires dart:html import which may not be available in all contexts
        // For now, we'll just log that we tried
        if (kDebugMode) {
          print('[KeyboardScroll] Web window scroll attempted (delta: $delta)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[KeyboardScroll] Web scroll fallback failed: $e');
      }
    }
  }
  
  /// Search ancestor elements for a Scrollable widget
  static ScrollableState? _searchAncestorsForScrollable(BuildContext context) {
    ScrollableState? found;
    try {
      final element = context as Element;
      
      // First, try ancestors (most common case)
      element.visitAncestorElements((ancestor) {
        final scrollable = Scrollable.maybeOf(ancestor);
        if (scrollable != null) {
          found = scrollable;
          return false; // Stop searching
        }
        return true; // Continue searching
      });
      
      // If not found in ancestors, try searching descendants
      if (found == null) {
        element.visitChildElements((child) {
          final scrollable = Scrollable.maybeOf(child);
          if (scrollable != null) {
            found = scrollable;
            return; // Found it
          }
          // Recursively search deeper
          try {
            final childScrollable = _searchDescendantsForScrollable(child);
            if (childScrollable != null) {
              found = childScrollable;
              return;
            }
          } catch (e) {
            // Continue searching other children
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('[KeyboardScroll] Error searching for scrollable: $e');
      }
    }
    return found;
  }
  
  /// Recursively search descendant elements for a Scrollable widget
  static ScrollableState? _searchDescendantsForScrollable(Element element) {
    ScrollableState? found;
    try {
      element.visitChildElements((child) {
        final scrollable = Scrollable.maybeOf(child);
        if (scrollable != null) {
          found = scrollable;
          return; // Found it
        }
        // Search deeper
        final deeper = _searchDescendantsForScrollable(child);
        if (deeper != null) {
          found = deeper;
          return;
        }
      });
    } catch (e) {
      // Element might not support child visiting
    }
    return found;
  }
  
}

/// NavigatorObserver that tracks the current route context
class KeyboardScrollNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateContext(route);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateContext(previousRoute);
    }
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateContext(newRoute);
    }
  }
  
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute != null) {
      _updateContext(previousRoute);
    }
  }
  
  void _updateContext(Route<dynamic> route) {
    final navigator = route.navigator;
    if (navigator != null) {
      final context = navigator.context;
      GlobalKeyboardScrollHandler.setCurrentRouteContext(context);
      if (kDebugMode) {
        print('[KeyboardScroll] NavigatorObserver updated context from route: ${route.settings.name ?? route.settings.arguments}');
      }
    }
  }
}

/// Widget that provides global keyboard scrolling functionality
/// by maintaining a global context reference
class GlobalKeyboardScrollWrapper extends StatefulWidget {
  final Widget child;
  
  const GlobalKeyboardScrollWrapper({
    super.key,
    required this.child,
  });
  
  @override
  State<GlobalKeyboardScrollWrapper> createState() => _GlobalKeyboardScrollWrapperState();
}

class _GlobalKeyboardScrollWrapperState extends State<GlobalKeyboardScrollWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateContext();
      _focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateContext();
    });
  }
  
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        KeyboardController.up();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        KeyboardController.down();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        KeyboardController.left();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        KeyboardController.right();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        KeyboardController.enter();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
  
  @override
  Widget build(BuildContext context) {
    // Update global context whenever the widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateContext();
    });
    
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      canRequestFocus: true,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
  
  void _updateContext() {
    // Use the widget's context directly - this should be closer to the actual page content
    GlobalKeyboardScrollHandler.setCurrentRouteContext(context);
    
    // Also try to find and register any PrimaryScrollController in this context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final primaryScrollController = PrimaryScrollController.maybeOf(context);
        if (primaryScrollController != null && kDebugMode) {
          print('[KeyboardScroll] Found PrimaryScrollController in context');
        }
      } catch (e) {
        // Ignore
      }
    });
    
    if (kDebugMode) {
      final route = ModalRoute.of(context);
      print('[KeyboardScroll] Updated context. Route: ${route?.settings.name ?? "unknown"}');
    }
  }
}


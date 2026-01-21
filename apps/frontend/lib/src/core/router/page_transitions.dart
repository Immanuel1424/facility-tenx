import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Utility class for creating consistent page transitions in go-router
class PageTransitions {
  /// Standard animation duration for page transitions
  static const Duration transitionDuration = Duration(milliseconds: 300);

  /// Standard animation curve for smooth transitions
  static const Curve transitionCurve = Curves.easeInOut;

  /// Creates a page with slide transition from right to left (forward navigation)
  /// Used when navigating to a new page (pushing)
  /// 
  /// Animation behavior:
  /// - Forward (push): Current page slides in from right (Offset(1.0, 0.0) -> Offset(0.0, 0.0))
  /// - Reverse (pop): Current page slides out to right (Offset(0.0, 0.0) -> Offset(1.0, 0.0))
  /// 
  /// The previous page's animation is handled by Flutter automatically based on its own
  /// transition definition. Since all pages use the same transition, the previous page
  /// will slide in from left when popping (its animation reverses).
  static Page<T> slideFromRight<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animate the current page
        // When pushing: animation goes 0.0 -> 1.0, so slides in from right
        // When popping: animation reverses 1.0 -> 0.0, so slides out to right
        // 
        // Note: Flutter automatically reverses the animation when popping.
        // The previous page's visibility is handled automatically - it becomes
        // visible as the current page slides out to the right.
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Start from right
            end: Offset.zero, // End at center
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: transitionCurve,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: transitionDuration,
    );
  }

  /// Creates a page with slide transition from left to right (backward navigation)
  /// Used when navigating back (popping)
  /// When pushing forward, the animation automatically reverses (slides out to left)
  static Page<T> slideFromLeft<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Forward (push): slides in from left (-1.0 -> 0.0)
        // Reverse (pop): slides out to left (0.0 -> -1.0)
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0), // Start from left
            end: Offset.zero, // End at center
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: transitionCurve,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: transitionDuration,
    );
  }

  /// Creates a page with fade transition
  /// Used for splash screens and initial routes
  static Page<T> fade<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: transitionCurve,
          ),
          child: child,
        );
      },
      transitionDuration: transitionDuration,
    );
  }

  /// Creates a page with slide transition with automatic direction detection
  /// Uses slideFromRight for forward navigation, which automatically reverses
  /// when popping (slides out to right, revealing the previous page)
  /// 
  /// Note: Flutter's PageRouteBuilder automatically reverses animations on pop,
  /// so we always use slideFromRight and let Flutter handle the reverse.
  static Page<T> slideAuto<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    // Always use slideFromRight for forward navigation
    // Flutter will automatically reverse the animation when popping:
    // - Push: slides in from right (Offset(1.0, 0.0) -> Offset(0.0, 0.0))
    // - Pop: slides out to right (Offset(0.0, 0.0) -> Offset(1.0, 0.0))
    return slideFromRight<T>(context, state, child);
  }
}

/// Custom transition page for go-router
class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required super.key,
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.maintainState = true,
    this.fullscreenDialog = false,
  });

  final Widget child;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) transitionsBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final bool opaque;
  final bool barrierDismissible;
  final bool maintainState;
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      opaque: opaque,
      barrierDismissible: barrierDismissible,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
}


// File: lib/widgets/animated_page_transition.dart
import 'package:flutter/material.dart';

enum PageTransitionType {
  /// Slides in from the right while fading.
  slideFade,

  /// Fades in with a slight scale-up.
  fadeScale,
}

/// Reusable, Flutter-native page transitions built on [PageRouteBuilder].
class AppTransitions {
  AppTransitions._();

  static const Duration _duration = Duration(milliseconds: 450);

  static Route<T> route<T>(
    Widget page, {
    PageTransitionType type = PageTransitionType.slideFade,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        switch (type) {
          case PageTransitionType.slideFade:
            final outgoing = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.1, 0),
              ).animate(outgoing),
              child: FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.15, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              ),
            );
          case PageTransitionType.fadeScale:
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
                child: child,
              ),
            );
        }
      },
    );
  }

  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    PageTransitionType type = PageTransitionType.slideFade,
  }) {
    return Navigator.of(context).push<T>(route<T>(page, type: type));
  }

  static Future<T?> pushReplacement<T extends Object?>(
    BuildContext context,
    Widget page, {
    PageTransitionType type = PageTransitionType.slideFade,
  }) {
    return Navigator.of(context)
        .pushReplacement<T, Object?>(route<T>(page, type: type));
  }
}

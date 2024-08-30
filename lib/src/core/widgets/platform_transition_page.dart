import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Define your custom page transitions for both platforms
class PlatformTransitionPage<T> extends Page<T> {
  final Widget child;
  final bool isCupertino;
  final bool disableAnimation;

  const PlatformTransitionPage({
    required this.child,
    this.isCupertino = false,
    this.disableAnimation = false,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    if (disableAnimation) {
      return PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        settings: this,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    }
    if (isCupertino) {
      return CupertinoPageRoute<T>(
        builder: (context) => child,
        settings: this,
      );
    } else {
      return MaterialPageRoute<T>(
        builder: (context) => child,
        settings: this,
      );
    }
  }
}

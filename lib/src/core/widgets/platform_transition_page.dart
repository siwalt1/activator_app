import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Define your custom page transitions for both platforms
class PlatformTransitionPage<T> extends Page<T> {
  final Widget child;
  final bool isCupertino;

  const PlatformTransitionPage({
    required this.child,
    required this.isCupertino,
  });

  @override
  Route<T> createRoute(BuildContext context) {
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

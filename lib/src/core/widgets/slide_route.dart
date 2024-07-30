import 'package:activator_app/src/core/utils/slide_direction.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlidePageTransition extends CustomTransitionPage<void> {
  final SlideDirection direction;
  final Widget child;
  final Duration duration;

  SlidePageTransition({
    required this.direction,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          key: ValueKey(child),
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.leftToRight:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.rightToLeft:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.topToBottom:
                begin = const Offset(0.0, -1.0);
                break;
              case SlideDirection.bottomToTop:
                begin = const Offset(0.0, 1.0);
                break;
            }
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: duration,
        );
}

import 'package:flutter/material.dart';

PageRouteBuilder createRoute(Widget destination) {
  return PageRouteBuilder(
  pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return destination;
  },
  transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child:  SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0, 0.0),
        ).animate(secondaryAnimation),
        child: child,
      ),
    );
  },
);
}
import 'package:flutter/material.dart';

class CustomNavigator {
  static const _duration = Duration(milliseconds: 300);

  static PageRouteBuilder<T> _route<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Future<T?> pushFade<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(context, _route<T>(page));
  }

  static Future<T?> pushReplacementFade<T, TO>(
      BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, TO>(context, _route<T>(page));
  }

  static Future<T?> pushAndRemoveUntilFade<T>(
      BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      _route<T>(page),
      (route) => false,
    );
  }
}
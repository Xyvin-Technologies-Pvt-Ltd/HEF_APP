import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void pop() {
    return navigatorKey.currentState!.pop();
  }

  Future<dynamic> pushNamed(String? routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName!, arguments: arguments);
  }
    Future<dynamic> pushNamedReplacement(String? routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName!, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(String? routeName,
      {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName!, (route) => false,
        arguments: arguments);
  }

  Future<dynamic> pushRemoveUntil(Widget child) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => child,
        ),
        (route) => false);
  }

  void popUntil(
    String? routeName,
  ) {
    return navigatorKey.currentState!
        .popUntil((route) => route.settings.name == routeName);
  }

  Future<dynamic> popAndPushNamed(
    String routeName,
  ) {
    return navigatorKey.currentState!.popAndPushNamed(routeName);
  }

  Route navigatAnimated(Widget child) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

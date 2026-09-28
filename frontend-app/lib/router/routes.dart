import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String certificateDetail = '/certificate/:id';
  static const String signIn = '/signIn';
}

class Nav {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Future<T?>? pushNamed<T extends Object?>(String route, {Object? arguments}) => navigatorKey.currentState?.pushNamed<T>(route, arguments: arguments);
  static Future<T?>? pushReplacementNamed<T extends Object?, TO extends Object?>(String route, {Object? arguments, TO? result}) => navigatorKey.currentState?.pushReplacementNamed<T, TO>(route, arguments: arguments, result: result);
  static Future<T?>? pushNamedAndRemoveUntil<T extends Object?>(String route, RoutePredicate predicate, {Object? arguments}) => navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(route, predicate, arguments: arguments);
  static void pop<T extends Object?>([T? result]) => navigatorKey.currentState?.pop<T>(result);
}
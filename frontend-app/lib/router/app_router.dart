import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizacao_certificados/router/routes.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/modules/auth/auth_service.dart';

typedef PageBuilder = Widget Function(BuildContext context, GoRouterState state);

class RouteDefinition {
  const RouteDefinition({required this.path, required this.builder, this.authRequired = false});
  final String path;
  final PageBuilder builder;
  final bool authRequired;
}

abstract class RouteModule {
  List<RouteDefinition> get routes;
}

class RouteRegistry {
  static final Map<String, RouteDefinition> _routes = <String, RouteDefinition>{};

  static void registerAll(Iterable<RouteDefinition> defs) {
    for (final def in defs) {
      _routes[def.path] = def;
    }
  }

  static List<RouteDefinition> all() => _routes.values.toList(growable: false);
  static bool isProtected(String path) => _routes[path]?.authRequired ?? false;
}

class AppGoRouter {
  AppGoRouter._();
  static GoRouter? _router;

  static GoRouter router() => _router ??= _create();

  static GoRouter _create() {
    final defs = RouteRegistry.all();

    final routes = <RouteBase>[
      for (final d in defs)
        GoRoute(
          path: d.path,
          name: d.path,
          builder: (context, state) => d.builder(context, state),
        ),
    ];

    final auth = Injector.I.isRegistered<AuthService>() ? Injector.I.get<AuthService>() : AuthService();

    return GoRouter(
      navigatorKey: Nav.navigatorKey,
      initialLocation: AppRoutes.splash,
      routes: routes,
      refreshListenable: auth,
      redirect: (context, state) {
        final isLogged = auth.isLoggedInSync;
        final loc = state.matchedLocation;

        if (!isLogged && loc != AppRoutes.login) return AppRoutes.login;
        if (isLogged && (loc == AppRoutes.login || loc == AppRoutes.splash)) return AppRoutes.home;

        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(child: Text('Route not found: ${state.matchedLocation}')),
      ),
    );
  }
}

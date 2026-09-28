import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/core/modules/app_module.dart';
import 'package:organizacao_certificados/pages/splash_page.dart';
import 'package:organizacao_certificados/router/app_router.dart';
import 'package:organizacao_certificados/router/routes.dart';

class SplashModule extends AppModule {
  @override
  void registerServices(Injector i) {}

  @override
  List<RouteDefinition> get routes => [
        RouteDefinition(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
      ];
}

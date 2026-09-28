import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/router/app_router.dart';

abstract class AppModule {
  void registerServices(Injector i);
  List<RouteDefinition> get routes;
}

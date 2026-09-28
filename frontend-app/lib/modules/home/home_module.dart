import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/core/modules/app_module.dart';
import 'package:organizacao_certificados/modules/home/home_service.dart';
import 'package:organizacao_certificados/pages/home_page.dart';
import 'package:organizacao_certificados/pages/certificate_detail_page.dart';
import 'package:organizacao_certificados/router/app_router.dart';
import 'package:organizacao_certificados/router/routes.dart';

class HomeModule extends AppModule {
  @override
  void registerServices(Injector i) {
     i.registerSingleton<HomeService>(HomeService());
  }

  @override
  List<RouteDefinition> get routes => [
        RouteDefinition(path: AppRoutes.home, builder: (_, __) => const HomePage(), authRequired: true),
        RouteDefinition(
          path: AppRoutes.certificateDetail,
          builder: (_, state) {
            final id = state.pathParameters['id'] ?? '';
            return CertificateDetailPage(certId: id);
          },
          authRequired: true,
        ),
      ];
}

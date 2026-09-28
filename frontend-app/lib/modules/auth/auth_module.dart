import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/core/modules/app_module.dart';
import 'package:organizacao_certificados/modules/auth/auth_service.dart';
import 'package:organizacao_certificados/pages/login_page.dart';
import 'package:organizacao_certificados/pages/signin_page.dart';
import 'package:organizacao_certificados/router/app_router.dart';
import 'package:organizacao_certificados/router/routes.dart';
import 'package:organizacao_certificados/utils/api_client.dart';

class AuthModule extends AppModule {
  @override
  void registerServices(Injector i) {
    i.registerSingleton<ApiClient>(ApiClient(
      onUnauthorized: () async {
        await i.get<AuthService>().logOut();
        AppGoRouter.router().go(AppRoutes.login);
      },
    ));
    i.registerSingleton<AuthService>(
      AuthService(apiClient: i.get<ApiClient>()),
    );
  }

  @override
  List<RouteDefinition> get routes => [
        RouteDefinition(
            path: AppRoutes.login, builder: (_, __) => const LoginPage()),
        RouteDefinition(
            path: AppRoutes.signIn, builder: (_, __) => const SignInPage()),
      ];
}

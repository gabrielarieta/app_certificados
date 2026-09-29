import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:organizacao_certificados/modules/auth/auth_service.dart';
import 'package:organizacao_certificados/theme.dart';
import 'package:organizacao_certificados/router/app_router.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/core/modules/app_module.dart';
import 'package:organizacao_certificados/modules/core/splash_module.dart';
import 'package:organizacao_certificados/modules/auth/auth_module.dart';
import 'package:organizacao_certificados/modules/home/home_module.dart';
import 'package:organizacao_certificados/utils/storage_keys_utils.dart';
import 'package:organizacao_certificados/l10n/app_localizations.dart';

Future<void> main() async {
  await initializeDateFormatting('pt_BR');
  await dotenv.load(fileName: ".env");
  _bootstrapModules();
  await checkIfLoggedIn();
  runApp(const MyApp());
}

void _bootstrapModules() {
  Injector.I.registerSingleton<StorageKeysUtils>(StorageKeysUtils());
  final List<AppModule> modules = [SplashModule(), AuthModule(), HomeModule()];
  for (final m in modules) {
    m.registerServices(Injector.I);
  }
  final routes = modules.expand((m) => m.routes);
  RouteRegistry.registerAll(routes);
}

Future<void> checkIfLoggedIn() async {
  await Injector.I.get<AuthService>().loadToken();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Organização de Certificados',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: AppGoRouter.router(),
    );
  }
}

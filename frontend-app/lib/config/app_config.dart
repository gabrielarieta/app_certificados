import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String get apiUrl {
    const fromDefine = String.fromEnvironment('API_URL', defaultValue: '');
    final configuredValue = fromDefine.isNotEmpty ? fromDefine : dotenv.env['API_URL'];
    final value = configuredValue?.trim() ?? '';

    if (value.isEmpty) {
      throw StateError(
        'API_URL is not configured. Add it to frontend-app/.env or pass --dart-define=API_URL=http://localhost:3000.',
      );
    }

    return value;
  }
}

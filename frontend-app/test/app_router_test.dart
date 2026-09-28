import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organizacao_certificados/modules/auth/auth_service.dart';
import 'package:organizacao_certificados/router/app_router.dart';
import 'package:organizacao_certificados/router/routes.dart';

void main() {
  group('redirectForAuth', () {
    test('allows unauthenticated users to reach login and registration', () {
      expect(
        redirectForAuth(isLoggedIn: false, location: AppRoutes.login),
        isNull,
      );
      expect(
        redirectForAuth(isLoggedIn: false, location: AppRoutes.signIn),
        isNull,
      );
    });

    test('redirects an unauthenticated user away from protected routes', () {
      RouteRegistry.registerAll([
        RouteDefinition(
          path: AppRoutes.home,
          builder: (_, __) => const SizedBox.shrink(),
          authRequired: true,
        ),
      ]);

      expect(
        redirectForAuth(isLoggedIn: false, location: AppRoutes.home),
        AppRoutes.login,
      );
    });

    test('redirects authenticated users away from auth routes', () {
      expect(
        redirectForAuth(isLoggedIn: true, location: AppRoutes.signIn),
        AppRoutes.home,
      );
    });
  });

  group('isJwtValid', () {
    test('accepts a token with a future expiration', () {
      final now = DateTime.utc(2026, 1, 1);
      final token = _tokenWithExpiration(now.add(const Duration(minutes: 1)));

      expect(isJwtValid(token, now: now), isTrue);
    });

    test('rejects expired and malformed tokens', () {
      final now = DateTime.utc(2026, 1, 1);
      final expired = _tokenWithExpiration(now);

      expect(isJwtValid(expired, now: now), isFalse);
      expect(isJwtValid('not-a-jwt', now: now), isFalse);
    });
  });
}

String _tokenWithExpiration(DateTime expiration) {
  final payload = base64Url
      .encode(utf8.encode(
          jsonEncode({'exp': expiration.millisecondsSinceEpoch ~/ 1000})))
      .replaceAll('=', '');
  return 'header.$payload.signature';
}

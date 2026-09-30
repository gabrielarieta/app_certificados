import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:organizacao_certificados/config/app_config.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/utils/api_client.dart';
import 'package:organizacao_certificados/utils/storage_keys_utils.dart';

class AuthService extends ChangeNotifier {
  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final String _baseUrl = AppConfig.apiUrl;
  static const _tokenKey = 'auth_token';

  bool _isLoggedIn = false;
  bool get isLoggedInSync => _isLoggedIn;

  Future<bool> logIn(String email, String password) async {
    final response = await _apiClient.request(
      method: 'POST',
      uri: Uri.parse('$_baseUrl/auth/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    final token = responseBody['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException(
          502, 'The server returned an invalid login response.');
    }

    await Injector.I.get<StorageKeysUtils>().setKey(_tokenKey, token);
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  Future<bool> signup(name, email, password) async {
    await _apiClient.request(
      method: 'POST',
      uri: Uri.parse('$_baseUrl/auth/signup'),
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return true;
  }

  Future<void> loadToken() async {
    final token = await Injector.I.get<StorageKeysUtils>().getKey(_tokenKey);
    _isLoggedIn = token is String && isJwtValid(token);
    if (!_isLoggedIn && token != null) {
      await Injector.I.get<StorageKeysUtils>().deleteKey(_tokenKey);
    }
    notifyListeners();
  }

  Future<void> logOut() async {
    await Injector.I.get<StorageKeysUtils>().deleteKey(_tokenKey);
    _isLoggedIn = false;
    notifyListeners();
  }
}

bool isJwtValid(String token, {DateTime? now}) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return false;
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map<String, dynamic> || payload['exp'] is! num) {
      return false;
    }
    final expiresAt = (payload['exp'] as num).toDouble();
    final currentTime = (now ?? DateTime.now()).millisecondsSinceEpoch / 1000;
    return expiresAt > currentTime;
  } on FormatException {
    return false;
  }
}

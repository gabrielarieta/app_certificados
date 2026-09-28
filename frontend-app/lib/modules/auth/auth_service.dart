import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/utils/storage_keys_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService extends ChangeNotifier {

  final String _baseUrl = dotenv.env['API_URL']!;
  static const _tokenKey = 'auth_token';

  bool _isLoggedIn = false;
  bool get isLoggedInSync => _isLoggedIn;

  Future logIn(email, password) async {
    final body =  {
      'email': email,
      'password': password
      };

    http.Response response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body)
      );

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if(responseBody.containsKey('token')) {
      Injector.I.get<StorageKeysUtils>().setKey(_tokenKey, responseBody['token']);
      _isLoggedIn = true;
      notifyListeners();
    } else {
      throw Exception('Login failed: ${responseBody['message'] ?? 'Unknown error'}');
    }

    return response;
  }

  Future<bool> signup(name, email, password) async {
    final url = Uri.parse('$_baseUrl/auth/signup');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    return response.statusCode == 201;
  }

  Future<void> loadToken() async {
    final token = await Injector.I.get<StorageKeysUtils>().getKey(_tokenKey);
    _isLoggedIn = token != null && token.isNotEmpty;
  }

  void logOut() {
      Injector.I.get<StorageKeysUtils>().deleteKey(_tokenKey);
      _isLoggedIn = false;
      notifyListeners();
    }
}

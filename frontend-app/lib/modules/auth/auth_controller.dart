import 'package:organizacao_certificados/modules/auth/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  String? _token;
  String? get token => _token;

  Future login(String email, String password) async {
    return await _authService.logIn(email, password);
  }

  Future<void> logout() async {
    _authService.logOut();
  }
}

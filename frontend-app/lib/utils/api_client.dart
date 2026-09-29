import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/utils/storage_keys_utils.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required this.onUnauthorized,
    http.Client? client,
    Future<String?> Function()? tokenProvider,
    this.timeout = const Duration(seconds: 15),
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider ?? _readStoredToken;

  final Future<void> Function() onUnauthorized;
  final Duration timeout;
  final http.Client _client;
  final Future<String?> Function() _tokenProvider;

  Future<http.Response> request({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        ...?headers,
      });
    final token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamedResponse = await _client.send(request).timeout(timeout);
      final response =
          await http.Response.fromStream(streamedResponse).timeout(timeout);
      if (response.statusCode == 401) await onUnauthorized();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, _errorMessage(response));
      }
      return response;
    } on TimeoutException {
      throw const ApiException(0, 'The request timed out. Please try again.');
    }
  }

  Future<http.Response> sendMultipart({
    required String method,
    required Uri uri,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    void Function(double progress)? onProgress,
  }) async {
    final request = http.MultipartRequest(method, uri)
      ..fields.addAll(fields)
      ..files.addAll(files);
    final token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    onProgress?.call(0);
    final streamedResponse = await _client.send(request).timeout(timeout);
    final response =
        await http.Response.fromStream(streamedResponse).timeout(timeout);
    onProgress?.call(1);
    if (response.statusCode == 401) await onUnauthorized();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(response));
    }
    return response;
  }

  static Future<String?> _readStoredToken() async {
    return Injector.I.get<StorageKeysUtils>().getKey('auth_token');
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is List) return message.join(', ');
        if (message is String && message.isNotEmpty) return message;
      }
    } on FormatException {
      if (response.body.isNotEmpty) return response.body;
    }
    return 'Request failed with status ${response.statusCode}.';
  }
}

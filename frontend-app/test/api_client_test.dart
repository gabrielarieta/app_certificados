import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:organizacao_certificados/utils/api_client.dart';

void main() {
  test('adds the stored bearer token to requests', () async {
    final client = _StubClient((request) => _response(request, 200, '{}'));
    final apiClient = ApiClient(
      client: client,
      tokenProvider: () async => 'valid-token',
      onUnauthorized: () async {},
    );

    await apiClient.request(
      method: 'GET',
      uri: Uri.parse('https://example.test/certificates'),
    );

    expect(client.lastRequest?.headers['Authorization'], 'Bearer valid-token');
  });

  test('logs out and exposes the decoded error on 401', () async {
    var loggedOut = false;
    final client = _StubClient(
      (request) => _response(request, 401, '{"message":"Session expired"}'),
    );
    final apiClient = ApiClient(
      client: client,
      tokenProvider: () async => 'expired-token',
      onUnauthorized: () async => loggedOut = true,
    );

    await expectLater(
      apiClient.request(
        method: 'GET',
        uri: Uri.parse('https://example.test/certificates'),
      ),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.message, 'message', 'Session expired'),
      ),
    );
    expect(loggedOut, isTrue);
  });
}

class _StubClient extends http.BaseClient {
  _StubClient(this.handler);

  final http.StreamedResponse Function(http.BaseRequest request) handler;
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    return handler(request);
  }
}

http.StreamedResponse _response(
  http.BaseRequest request,
  int statusCode,
  String body,
) {
  return http.StreamedResponse(
    Stream<Uint8List>.value(Uint8List.fromList(utf8.encode(body))),
    statusCode,
    request: request,
  );
}
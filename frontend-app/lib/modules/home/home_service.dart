import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/models/certificate.dart';
import 'package:organizacao_certificados/models/certificate_files.dart';
import 'package:organizacao_certificados/utils/storage_keys_utils.dart';
import 'package:path_provider/path_provider.dart';

class HomeService {
  final _baseUrl = dotenv.env['API_URL']!;

  Future<List<Certificate>> getCertificates() async {
    final url = Uri.parse('$_baseUrl/certificates');
    final http.Response response =
        await http.get(url, headers: await _buildHeaders());

    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao buscar certificados: ${jsonDecode(response.body)['message']}');
    }

    final List<dynamic> body = jsonDecode(response.body);
    return body.map((json) => Certificate.fromJson(json)).toList();
  }

  Future<Object> getCertificateById(String id) async {
    final url = Uri.parse('$_baseUrl/certificates/$id');

    final http.Response response =
        await http.get(url, headers: await _buildHeaders());
    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Certificate.fromJson(data);
      } else {
        throw Exception('Error trying to get certificate');
      }
    } catch (error) {
      return {'status': response.statusCode, 'message': error};
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await Injector.I.get<StorageKeysUtils>().getKey('auth_token');
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<void> openCertificateFile(CertificateFile file) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/certificate-files/${file.id}'),
        headers: await _buildHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Unable to download certificate file');
      }

      final fileData = jsonDecode(response.body) as Map<String, dynamic>;
      final bytes = base64Decode(fileData['data'] as String);

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${file.fileName}';

      final f = File(filePath);
      await f.writeAsBytes(bytes);

      await OpenFilex.open(filePath);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao abrir arquivo ${file.fileName}: $e");
      }
    }
  }
}

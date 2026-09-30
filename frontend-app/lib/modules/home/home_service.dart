import 'dart:convert';
import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:organizacao_certificados/config/app_config.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/models/certificate.dart';
import 'package:organizacao_certificados/models/certificate_files.dart';
import 'package:organizacao_certificados/utils/api_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class HomeService {
  HomeService({ApiClient? apiClient})
      : _baseUrl = AppConfig.apiUrl,
        _apiClient = apiClient ?? Injector.I.get<ApiClient>();

  final String _baseUrl;
  final ApiClient _apiClient;

  Future<List<Certificate>> getCertificates() async {
    final url = Uri.parse('$_baseUrl/certificates');
    final response = await _apiClient.request(method: 'GET', uri: url);

    final List<dynamic> body = jsonDecode(response.body);
    return body.map((json) => Certificate.fromJson(json)).toList();
  }

  Future<Certificate> getCertificateById(String id) async {
    final url = Uri.parse('$_baseUrl/certificates/$id');
    final response = await _apiClient.request(method: 'GET', uri: url);
    return Certificate.fromJson(jsonDecode(response.body));
  }

  Future<Certificate> createCertificate({
    required String title,
    required String description,
    required String issuedBy,
    required DateTime issuedOn,
    required List<http.MultipartFile> files,
    void Function(double progress)? onProgress,
  }) async {
    final response = await _apiClient.sendMultipart(
      method: 'POST',
      uri: Uri.parse('$_baseUrl/certificates'),
      fields: {
        'title': title,
        'description': description,
        'issuedBy': issuedBy,
        'issuedOn': issuedOn.toIso8601String(),
      },
      files: files,
      onProgress: onProgress,
    );
    return Certificate.fromJson(jsonDecode(response.body));
  }

  Future<Certificate> updateCertificate(
    String id, {
    String? title,
    String? description,
    String? issuedBy,
    DateTime? issuedOn,
  }) async {
    final response = await _apiClient.request(
      method: 'PATCH',
      uri: Uri.parse('$_baseUrl/certificates/$id'),
      body: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (issuedBy != null) 'issuedBy': issuedBy,
        if (issuedOn != null) 'issuedOn': issuedOn.toIso8601String(),
      },
    );
    return Certificate.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteCertificate(String id) async {
    await _apiClient.request(
      method: 'DELETE',
      uri: Uri.parse('$_baseUrl/certificates/$id'),
    );
  }

  Future<void> deleteCertificateFile(String id) async {
    await _apiClient.request(
      method: 'DELETE',
      uri: Uri.parse('$_baseUrl/certificate-files/$id'),
    );
  }

  Future<Certificate> appendCertificateFiles(
    String id,
    List<http.MultipartFile> files, {
    void Function(double progress)? onProgress,
  }) async {
    final response = await _apiClient.sendMultipart(
      method: 'POST',
      uri: Uri.parse('$_baseUrl/certificates/$id/files'),
      fields: const {},
      files: files,
      onProgress: onProgress,
    );
    return Certificate.fromJson(jsonDecode(response.body));
  }

  Future<void> openCertificateFile(CertificateFile file) async {
    final response = await _apiClient.request(
      method: 'GET',
      uri: Uri.parse('$_baseUrl/certificate-files/${file.id}'),
    );
    final fileData = jsonDecode(response.body) as Map<String, dynamic>;
    final bytes = base64Decode(fileData['data'] as String);

    final tempDir = await getTemporaryDirectory();
    final safeFileName = sanitizeTemporaryFileName(file.fileName);
    final filePath = '${tempDir.path}/$safeFileName';

    final output = File(filePath);
    await output.writeAsBytes(bytes);

    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }
}

String sanitizeTemporaryFileName(String fileName) {
  final baseName = fileName.split(RegExp(r'[/\\]')).last;
  final sanitized = baseName
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
      .replaceAll('..', '_');
  return sanitized.isEmpty || sanitized == '.' ? 'certificate' : sanitized;
}

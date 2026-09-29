import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:organizacao_certificados/models/certificate.dart';
import 'package:organizacao_certificados/models/certificate_files.dart';
import 'package:organizacao_certificados/modules/home/home_service.dart';
import 'package:organizacao_certificados/utils/api_client.dart';
import 'package:organizacao_certificados/widgets/certificates_data_table.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:3000');
  });

  testWidgets('shows loading, supports retry, and shows an empty state', (
    tester,
  ) async {
    final firstResponse = Completer<List<Certificate>>();
    final retryResponse = Completer<List<Certificate>>();
    final service =
        _StubHomeService([firstResponse.future, retryResponse.future]);

    await tester.pumpWidget(_tableApp(service));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    firstResponse.completeError(Exception('Network error'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load certificates.'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    retryResponse.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('No certificates yet.'), findsOneWidget);
  });

  testWidgets('shows a snackbar when a certificate file cannot be opened', (
    tester,
  ) async {
    final service = _StubHomeService(
      [
        Future.value([_certificateWithFile()])
      ],
      openFileError: Exception('Viewer unavailable'),
    );

    await tester.pumpWidget(_tableApp(service));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.picture_as_pdf));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Unable to open certificate.pdf'), findsOneWidget);
  });

  test('sanitizes path components in temporary file names', () {
    expect(sanitizeTemporaryFileName('../../private/certificate.pdf'),
        'certificate.pdf');
    expect(sanitizeTemporaryFileName(r'..\private\certificate.pdf'),
        'certificate.pdf');
    expect(sanitizeTemporaryFileName('..'), '_');
  });
}

Widget _tableApp(HomeService service) {
  return MaterialApp(
    home: Scaffold(body: CertificatesDataTable(homeService: service)),
  );
}

Certificate _certificateWithFile() {
  return Certificate(
    id: 'certificate-id',
    title: 'Certificate',
    issuedBy: 'Issuer',
    issuedOn: DateTime(2026, 1, 1),
    certificateFiles: [
      CertificateFile(
        id: 'file-id',
        fileName: 'certificate.pdf',
        mimeType: 'application/pdf',
        size: 1024,
      ),
    ],
  );
}

class _StubHomeService extends HomeService {
  _StubHomeService(this.responses, {this.openFileError})
      : super(
          apiClient: ApiClient(
            onUnauthorized: () async {},
            tokenProvider: () async => null,
            client:
                MockClient((_) async => throw StateError('Unexpected request')),
          ),
        );

  final List<Future<List<Certificate>>> responses;
  final Object? openFileError;
  var _nextResponse = 0;

  @override
  Future<List<Certificate>> getCertificates() {
    return responses[_nextResponse++];
  }

  @override
  Future<void> openCertificateFile(CertificateFile file) async {
    if (openFileError != null) throw openFileError!;
  }
}

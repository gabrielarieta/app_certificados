import 'package:flutter_test/flutter_test.dart';
import 'package:organizacao_certificados/models/certificate_files.dart';

void main() {
  test('parses file metadata without eagerly loading file data', () {
    final file = CertificateFile.fromJson({
      '_id': 'file-id',
      'fileName': 'certificate.pdf',
      'mimeType': 'application/pdf',
      'size': 1024,
    });

    expect(file.id, 'file-id');
    expect(file.fileName, 'certificate.pdf');
    expect(file.data, isNull);
  });
}

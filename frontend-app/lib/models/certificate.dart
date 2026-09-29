import 'package:organizacao_certificados/models/certificate_files.dart';

class Certificate {
  final String id;
  final String title;
  final String? description;
  final String issuedBy;
  final DateTime issuedOn;
  final List<CertificateFile> certificateFiles;

  Certificate({
    required this.id,
    required this.title,
    this.description,
    required this.issuedBy,
    required this.issuedOn,
    required this.certificateFiles,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      issuedBy: json['issuedBy'],
      issuedOn: DateTime.parse(json['issuedOn'].toString()),
      certificateFiles: (json['certificateFiles'] as List<dynamic>?)
              ?.map((e) => CertificateFile.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'issuedBy': issuedBy,
      'issuedOn': issuedOn.toIso8601String(),
      'certificateFiles':
          certificateFiles.map((file) => file.toJson()).toList(),
    };
  }
}

import 'package:organizacao_certificados/models/certificate_files.dart';

class Certificate {
  final String id;
  final String title;
  final String? description;
  final String emitedBy;
  final String emitedOn;
  final List<CertificateFile> certificateFiles;

  Certificate({
    required this.id,
    required this.title,
    this.description,
    required this.emitedBy,
    required this.emitedOn,
    required this.certificateFiles,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      emitedBy: json['emitedBy'],
      emitedOn: json['emitedOn'],
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
      'emitedBy': emitedBy,
      'emitedOn': emitedOn,
      'certificateFiles':
      certificateFiles.map((file) => file.toJson()).toList(),
    };
  }
}
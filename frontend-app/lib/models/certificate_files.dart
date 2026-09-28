class CertificateFile {
  final String id;
  final String fileName;
  final String? data;
  final String mimeType;
  final int size;

  CertificateFile({
    required this.id,
    required this.fileName,
    this.data,
    required this.mimeType,
    required this.size,
  });

  factory CertificateFile.fromJson(Map<String, dynamic> json) {
    return CertificateFile(
      id: json['_id'],
      fileName: json['fileName'],
      data: json['data'] as String?,
      mimeType: json['mimeType'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fileName': fileName,
      'data': data,
      'mimeType': mimeType,
      'size': size,
    };
  }
}

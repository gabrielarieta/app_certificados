import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/models/certificate.dart';
import 'package:organizacao_certificados/modules/home/home_service.dart';
import 'package:organizacao_certificados/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class CertificateDetailPage extends StatefulWidget {
  const CertificateDetailPage({super.key, required this.certId});

  final String certId;

  @override
  State<CertificateDetailPage> createState() => _CertificateDetailPageState();
}

class _CertificateDetailPageState extends State<CertificateDetailPage> {
  late Future<Certificate> _certificateFuture;

  HomeService get _service => Injector.I.get<HomeService>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _certificateFuture = _service.getCertificateById(widget.certId);
  }

  Future<void> _deleteCertificate(Certificate certificate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteCertificateTitle),
        content: Text(AppLocalizations.of(context).deleteCertificateMessage),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deleteCertificate(certificate.id);
      if (mounted) context.pop(true);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  Future<void> _attachFiles(Certificate certificate) async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null) return;
    final files = <http.MultipartFile>[];
    for (final file in result.files.take(5)) {
      if (file.size > 1_000_000) continue;
      if (file.bytes != null) {
        files.add(http.MultipartFile.fromBytes('files', file.bytes!,
            filename: file.name));
      } else if (file.path != null) {
        files.add(await http.MultipartFile.fromPath('files', file.path!,
            filename: file.name));
      }
    }
    if (files.isEmpty) return;
    try {
      await _service.appendCertificateFiles(certificate.id, files);
      if (mounted) {
        setState(_load);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).fileAttached)),
        );
      }
    } catch (error) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).certificateDetails),
      ),
      body: FutureBuilder<Certificate>(
        future: _certificateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${AppLocalizations.of(context).unableToLoadCertificate} ${snapshot.error}',
              ),
            );
          }
          final certificate = snapshot.data!;
          return _buildDetails(certificate);
        },
      ),
    );
  }

  Widget _buildDetails(Certificate certificate) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          certificate.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        _DetailLine(
          label: AppLocalizations.of(context).issuer,
          value: certificate.issuedBy,
        ),
        _DetailLine(
          label: AppLocalizations.of(context).issueDate,
          value: DateFormat.yMMMMd('pt_BR').format(certificate.issuedOn),
        ),
        if ((certificate.description ?? '').isNotEmpty)
          _DetailLine(
            label: AppLocalizations.of(context).description,
            value: certificate.description!,
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () async {
                final changed = await context.push<bool>(
                  '/certificate/${Uri.encodeComponent(certificate.id)}/edit',
                  extra: certificate,
                );
                if (changed == true && mounted) setState(_load);
              },
              icon: const Icon(Icons.edit),
              label: Text(AppLocalizations.of(context).edit),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _deleteCertificate(certificate),
              icon: const Icon(Icons.delete_outline),
              label: Text(AppLocalizations.of(context).delete),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context).files,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        OutlinedButton.icon(
          onPressed: () => _attachFiles(certificate),
          icon: const Icon(Icons.attach_file),
          label: Text(AppLocalizations.of(context).attachFiles),
        ),
        ...certificate.certificateFiles.map(
          (file) => ListTile(
            leading: Icon(
              file.mimeType == 'application/pdf'
                  ? Icons.picture_as_pdf
                  : Icons.image,
            ),
            title: Text(file.fileName),
            trailing: IconButton(
              tooltip: AppLocalizations.of(context).openFile,
              icon: const Icon(Icons.open_in_new),
              onPressed: () async {
                try {
                  await _service.openCertificateFile(file);
                } catch (error) {
                  _showError(error);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

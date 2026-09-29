import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/models/certificate.dart';
import 'package:organizacao_certificados/modules/home/home_service.dart';
import 'package:organizacao_certificados/l10n/app_localizations.dart';

class CertificateFormPage extends StatefulWidget {
  const CertificateFormPage({super.key, this.initial});

  final Certificate? initial;

  @override
  State<CertificateFormPage> createState() => _CertificateFormPageState();
}

class _CertificateFormPageState extends State<CertificateFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _issuerController;
  late DateTime _issuedOn;
  List<PlatformFile> _files = [];
  bool _isSubmitting = false;
  double _progress = 0;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final certificate = widget.initial;
    _titleController = TextEditingController(text: certificate?.title ?? '');
    _descriptionController =
        TextEditingController(text: certificate?.description ?? '');
    _issuerController =
        TextEditingController(text: certificate?.issuedBy ?? '');
    _issuedOn = certificate?.issuedOn ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _issuerController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null) return;

    final validFiles = result.files
        .where((file) {
          final extension = file.extension?.toLowerCase();
          return extension != null &&
              {'jpg', 'jpeg', 'png', 'pdf'}.contains(extension) &&
              file.size <= 1_000_000;
        })
        .take(5)
        .toList();
    if (validFiles.length != result.files.length) {
      _showMessage(l10n.onlyAllowedFiles);
    }
    setState(() => _files = validFiles);
  }

  Future<List<http.MultipartFile>> _multipartFiles() async {
    final result = <http.MultipartFile>[];
    for (final file in _files) {
      if (file.bytes != null) {
        result.add(
          http.MultipartFile.fromBytes(
            'files',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null) {
        result.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path!,
            filename: file.name,
          ),
        );
      }
    }
    return result;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isEditing && _files.isEmpty) {
      _showMessage(AppLocalizations.of(context).selectAtLeastOneFile);
      return;
    }
    setState(() => _isSubmitting = true);
    final service = Injector.I.get<HomeService>();
    try {
      if (_isEditing) {
        await service.updateCertificate(
          widget.initial!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          issuedBy: _issuerController.text.trim(),
          issuedOn: _issuedOn,
        );
      } else {
        await service.createCertificate(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          issuedBy: _issuerController.text.trim(),
          issuedOn: _issuedOn,
          files: await _multipartFiles(),
          onProgress: (value) => setState(() => _progress = value),
        );
      }
      if (mounted) context.pop(true);
    } catch (error) {
      _showMessage('$error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: _issuedOn,
    );
    if (date != null) setState(() => _issuedOn = date);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? AppLocalizations.of(context).editCertificate
              : AppLocalizations.of(context).newCertificate,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).title),
              validator: (value) => value == null || value.trim().isEmpty
                  ? AppLocalizations.of(context).enterTitle
                  : null,
            ),
            TextFormField(
              controller: _issuerController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).issuer),
              validator: (value) => value == null || value.trim().isEmpty
                  ? AppLocalizations.of(context).enterIssuer
                  : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).description),
              maxLines: 3,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppLocalizations.of(context).issueDate),
              subtitle: Text(DateFormat.yMMMMd('pt_BR').format(_issuedOn)),
              trailing: IconButton(
                onPressed: _selectDate,
                icon: const Icon(Icons.event),
              ),
            ),
            if (!_isEditing) ...[
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _pickFiles,
                icon: const Icon(Icons.attach_file),
                label: Text(
                    AppLocalizations.of(context).selectFiles(_files.length)),
              ),
              ..._files.map(
                (file) => ListTile(
                  dense: true,
                  title: Text(file.name),
                  subtitle: Text('${(file.size / 1024).ceil()} KB'),
                  trailing: IconButton(
                    onPressed: () => setState(() => _files.remove(file)),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_isSubmitting && !_isEditing)
              LinearProgressIndicator(value: _progress == 0 ? null : _progress),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: const Icon(Icons.save),
              label: Text(
                _isEditing
                    ? AppLocalizations.of(context).saveChanges
                    : AppLocalizations.of(context).createCertificate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

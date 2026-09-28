import 'package:flutter/material.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/models/certificate.dart';
import 'package:organizacao_certificados/models/certificate_files.dart';
import 'package:organizacao_certificados/modules/home/home_service.dart';

class CertificatesDataTable extends StatefulWidget {
  const CertificatesDataTable({super.key, this.homeService});

  final HomeService? homeService;

  @override
  State<CertificatesDataTable> createState() => _CertificatesDataTableState();
}

class _CertificatesDataTableState extends State<CertificatesDataTable> {
  late final HomeService homeService =
      widget.homeService ?? Injector.I.get<HomeService>();
  final Map<String, bool> _expandedMap = {};
  String? _hoveredCertificateId;

  late Future<List<Certificate>> _certificatesFuture;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  void _loadCertificates() {
    _certificatesFuture = homeService.getCertificates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final tableHeight = MediaQuery.of(context).size.height * 0.5;

    return FutureBuilder<List<Certificate>>(
      future: _certificatesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            height: tableHeight,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: tableHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load certificates.'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(_loadCertificates),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        final certificates = snapshot.data ?? <Certificate>[];
        if (certificates.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No certificates yet.')),
          );
        }
        return _buildTable(
            context, certificates, theme, textTheme, tableHeight);
      },
    );
  }

  Future<void> _openCertificateFile(CertificateFile file) async {
    try {
      await homeService.openCertificateFile(file);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open ${file.fileName}: $error')),
      );
    }
  }

  Widget _buildTable(BuildContext context, List<Certificate> certificates,
      ThemeData theme, TextTheme textTheme, double tableHeight) {
    return SizedBox(
      height: tableHeight,
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 800,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: theme.colorScheme.primaryContainer,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(
                              'Título',
                              style: textTheme.titleMedium!.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer),
                            )),
                        Expanded(
                            flex: 2,
                            child: Text(
                              'Emitido por',
                              style: textTheme.titleMedium!.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              'Em',
                              style: textTheme.titleMedium!.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer),
                            )),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...certificates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cert = entry.value;
                    final isExpanded = _expandedMap[cert.id] ?? false;

                    final baseColor = index.isEven
                        ? theme.colorScheme.surface
                        : theme.colorScheme.surfaceContainerHighest;
                    final hoverColor =
                        theme.colorScheme.primary.withValues(alpha: 0.5);

                    return Column(
                      children: [
                        MouseRegion(
                          onEnter: (_) =>
                              setState(() => _hoveredCertificateId = cert.id),
                          onExit: (_) =>
                              setState(() => _hoveredCertificateId = null),
                          child: Container(
                            color: _hoveredCertificateId == cert.id
                                ? hoverColor
                                : (isExpanded
                                    ? theme.colorScheme.surfaceContainerHighest
                                    : baseColor),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(cert.title,
                                          style: textTheme.bodyMedium),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(cert.emitedBy,
                                          style: textTheme.bodyMedium),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(cert.emitedOn,
                                          style: textTheme.bodyMedium),
                                    )),
                                IconButton(
                                  icon: Icon(isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down),
                                  onPressed: () {
                                    setState(() =>
                                        _expandedMap[cert.id] = !isExpanded);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                color: theme.colorScheme.primaryContainer,
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text('Arquivo',
                                            style: textTheme.titleMedium!
                                                .copyWith(
                                                    color: theme.colorScheme
                                                        .onPrimaryContainer))),
                                    const SizedBox(width: 40),
                                  ],
                                ),
                              ),
                              ...cert.certificateFiles
                                  .asMap()
                                  .entries
                                  .map((fileEntry) {
                                final fileIndex = fileEntry.key;
                                final file = fileEntry.value;
                                final fileBaseColor = fileIndex.isEven
                                    ? theme.colorScheme.surface
                                    : theme.colorScheme.surfaceContainerHighest;

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  color: fileBaseColor,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(file.fileName,
                                              style: textTheme.bodyMedium)),
                                      IconButton(
                                        icon: Icon(
                                            file.mimeType == 'application/pdf'
                                                ? Icons.picture_as_pdf
                                                : Icons.image),
                                        onPressed: () =>
                                            _openCertificateFile(file),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

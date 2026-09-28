import 'package:flutter/material.dart';

class CertificateDetailPage extends StatelessWidget {
  const CertificateDetailPage({super.key, required this.certId});
  final String certId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Certificate $certId')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Icon(Icons.verified, color: Colors.blue), const SizedBox(width: 8), Text('Details', style: theme.textTheme.titleMedium)]),
                      const SizedBox(height: 12),
                      _DetailLine(label: 'Certificate ID', value: certId),
                      const SizedBox(height: 8),
                      _DetailLine(label: 'Name', value: 'Sample Certificate'),
                      const SizedBox(height: 8),
                      _DetailLine(label: 'Status', value: 'Active'),
                      const SizedBox(height: 8),
                      _DetailLine(label: 'Date', value: '2025-05-10'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Download PDF')),
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share), label: const Text('Share')),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium, softWrap: true)),
      ],
    );
  }
}

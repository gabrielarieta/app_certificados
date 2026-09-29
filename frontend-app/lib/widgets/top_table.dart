import 'package:flutter/material.dart';
import 'package:organizacao_certificados/widgets/certificates_data_table.dart';

class TopTableCard extends StatelessWidget {
  const TopTableCard({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_chart, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Lista de Certificados',
                        style: theme.textTheme.titleMedium),
                  ],
                ),
                IconButton(
                  tooltip: 'Create certificate',
                  onPressed: onCreate,
                  icon: Icon(Icons.add_outlined,
                      color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: screenHeight * 0.5,
              child: const CertificatesDataTable(),
            ),
          ],
        ),
      ),
    );
  }
}

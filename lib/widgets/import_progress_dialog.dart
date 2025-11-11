import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/product_import_service.dart';

class ImportProgressDialog extends StatelessWidget {
  final int currentIndex;
  final int totalProducts;
  final ImportResult? result;

  const ImportProgressDialog({
    super.key,
    required this.currentIndex,
    required this.totalProducts,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(result == null
          ? l10n.importingProducts
          : l10n.importComplete),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result == null) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.importingProductsProgress(currentIndex, totalProducts),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Icon(
              result!.errors > 0 ? Icons.warning : Icons.check_circle,
              color: result!.errors > 0 ? Colors.orange : Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            _buildResultSummary(context, l10n, result!),
          ],
        ],
      ),
      actions: result != null
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ]
          : null,
    );
  }

  Widget _buildResultSummary(
    BuildContext context,
    AppLocalizations l10n,
    ImportResult result,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultRow(
          context,
          l10n.imported,
          result.imported,
          Colors.green,
          Icons.check_circle_outline,
        ),
        _buildResultRow(
          context,
          l10n.skipped,
          result.skipped,
          Colors.orange,
          Icons.skip_next,
        ),
        _buildResultRow(
          context,
          l10n.errors,
          result.errors,
          Colors.red,
          Icons.error_outline,
        ),
        if (result.errorMessages.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            l10n.errorDetails,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.errorMessages
                    .map(
                      (msg) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          msg,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

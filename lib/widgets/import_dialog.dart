import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/product_import_service.dart';

class ImportDialog extends StatefulWidget {
  final Future<ImportResult> importFuture;
  final int totalProducts;

  const ImportDialog({
    super.key,
    required this.importFuture,
    required this.totalProducts,
  });

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  int _currentIndex = 0;
  ImportResult? _result;

  @override
  void initState() {
    super.initState();
    _waitForResult();
  }

  Future<void> _waitForResult() async {
    try {
      final result = await widget.importFuture;
      if (mounted) {
        setState(() {
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = ImportResult(
            imported: 0,
            skipped: 0,
            errors: 1,
            total: 0,
            errorMessages: ['Import failed: ${e.toString()}'],
          );
        });
      }
    }
  }

  void updateProgress(int currentIndex) {
    if (mounted) {
      setState(() {
        _currentIndex = currentIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        _result == null ? l10n.importingProducts : l10n.importComplete,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_result == null) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.importingProductsProgress(_currentIndex, widget.totalProducts),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Icon(
              _result!.errors > 0 ? Icons.warning : Icons.check_circle,
              color: _result!.errors > 0 ? Colors.orange : Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            _buildResultSummary(context, l10n, _result!),
          ],
        ],
      ),
      actions: _result != null
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

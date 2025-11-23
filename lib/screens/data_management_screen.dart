import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/custom_colors.dart';
import '../widgets/branded_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import '../services/diary_provider.dart';
import '../services/export_service.dart';
import '../services/product_export_service.dart';
import '../services/product_import_service.dart';
import '../widgets/conflict_resolution_dialog.dart';
import '../l10n/app_localizations.dart';
import '../exceptions/export_exceptions.dart';
import '../widgets/ui_helpers.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen>
    with UiHelpers {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: BrandedAppBar(
        title: l10n.dataManagement,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, l10n.dataExport),
          _buildExportDataOption(context),
          _buildExportProductsOption(context),
          const Divider(),
          _buildSectionHeader(context, l10n.dataImport),
          _buildImportProductsOption(context),
          const Divider(),
          _buildSectionHeader(context, l10n.cacheManagement),
          _buildClearCacheOption(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildExportDataOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.upload_file, color: context.customColors.exportColor),
      title: Text(l10n.exportDiaryEntries),
      subtitle: Text(l10n.exportDiaryEntriesDescription),
      onTap: () => _showExportOptionsDialog(context),
    );
  }

  Widget _buildExportProductsOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.inventory_2_outlined, color: Colors.teal),
      title: Text(l10n.exportProducts),
      subtitle: Text(l10n.exportProductsDescription),
      onTap: _handleExportProducts,
    );
  }

  Widget _buildImportProductsOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.download, color: Colors.indigo),
      title: Text(l10n.importProducts),
      subtitle: Text(l10n.importProductsDescription),
      onTap: _handleImportProducts,
    );
  }

  Widget _buildClearCacheOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading:
          Icon(Icons.delete_sweep, color: context.customColors.warningColor),
      title: Text(l10n.clearFrequentProductsCache),
      subtitle: Text(l10n.clearFrequentProductsDescription),
      onTap: _showClearCacheDialog,
    );
  }

  void _showClearCacheDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final provider =
                  Provider.of<DiaryProvider>(context, listen: false);
              await provider.clearFrequentProductsCache();

              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.cacheCleared),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
                foregroundColor: context.customColors.warningColor),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  Future<void> _showExportOptionsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectExportTimeframe),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(l10n.allTime),
              subtitle: Text(l10n.exportAllEntries),
              onTap: () {
                Navigator.pop(context);
                _performExport(null, null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.last7Days),
              subtitle: Text(l10n.exportLast7Days),
              onTap: () {
                Navigator.pop(context);
                final endDate = DateTime.now();
                final startDate = endDate.subtract(const Duration(days: 7));
                _performExport(startDate, endDate);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(l10n.last30Days),
              subtitle: Text(l10n.exportLast30Days),
              onTap: () {
                Navigator.pop(context);
                final endDate = DateTime.now();
                final startDate = endDate.subtract(const Duration(days: 30));
                _performExport(startDate, endDate);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performExport(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final exportService = ExportService();

    showLoadingDialog(context, l10n.exportingData);

    try {
      await exportService.exportDiaryEntriesToCSV(
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        Navigator.pop(context);
        showSuccessSnackbar(context, l10n.exportSuccess);
      }
    } on NoDataToExportException {
      if (mounted) {
        Navigator.pop(context);
        showErrorSnackbar(context, l10n.noDataToExport);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorSnackbar(context, l10n.exportError);
      }
    }
  }

  Future<void> _handleExportProducts() async {
    final l10n = AppLocalizations.of(context)!;
    final exportService = ProductExportService();

    showLoadingDialog(context, l10n.exportingData);

    try {
      await exportService.exportProductsToJSON();

      if (mounted) {
        Navigator.pop(context);
        showSuccessSnackbar(context, l10n.exportProductsSuccess);
      }
    } on NoProductsToExportException {
      if (mounted) {
        Navigator.pop(context);
        showErrorSnackbar(context, l10n.noProductsToExport);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorSnackbar(context, l10n.exportError);
      }
    }
  }

  Future<void> _handleImportProducts() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final filePath = result.files.single.path!;

    if (!mounted) return;

    final progressNotifier = ValueNotifier<int>(0);
    final importService = ProductImportService();
    final importFuture = importService.importProductsFromJSON(
      filePath,
      onConflict: (conflict) async {
        final resolution = await showDialog<ConflictResolution>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConflictResolutionDialog(
            existingProduct: conflict.existingProduct,
            importedProduct: conflict.importedProduct,
          ),
        );
        return resolution ?? ConflictResolution.skip;
      },
      onProgress: (currentIndex, total) {
        progressNotifier.value = currentIndex;
      },
    );

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ImportProgressDialog(
          importFuture: importFuture,
          progressNotifier: progressNotifier,
        ),
      );
    } finally {
      progressNotifier.dispose();
    }
  }
}

class _ImportProgressDialog extends StatelessWidget {
  final Future<ImportResult> importFuture;
  final ValueNotifier<int> progressNotifier;

  const _ImportProgressDialog({
    required this.importFuture,
    required this.progressNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<ImportResult>(
      future: importFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return AlertDialog(
              title: Text(l10n.importError),
              content: Text(snapshot.error.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ],
            );
          }

          final result = snapshot.data!;
          return AlertDialog(
            title: Text(l10n.importComplete),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.imported}: ${result.imported}'),
                Text('${l10n.skipped}: ${result.skipped}'),
                Text('${l10n.errors}: ${result.errors}'),
                if (result.errorMessages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorDetails,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...result.errorMessages.map((error) => Text('• $error')),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          );
        }

        return AlertDialog(
          title: Text(l10n.importingProducts),
          content: ValueListenableBuilder<int>(
            valueListenable: progressNotifier,
            builder: (context, progress, child) {
              return FutureBuilder<ImportResult>(
                future: importFuture,
                builder: (context, futureSnapshot) {
                  final totalProducts = futureSnapshot.hasData
                      ? futureSnapshot.data!.total
                      : progress;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: totalProducts > 0 ? progress / totalProducts : 0,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.importingProductsProgress(progress, totalProducts),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../l10n/app_localizations.dart';

enum ExportFormat { csv, json }

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  ExportFormat _selectedFormat = ExportFormat.csv;
  int? _entryCount;
  bool _isLoadingCount = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    // Set default date range to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
    _loadEntryCount();
  }

  Future<void> _loadEntryCount() async {
    if (_startDate == null || _endDate == null) return;

    setState(() {
      _isLoadingCount = true;
      _validationError = null;
    });

    try {
      final entries = await DatabaseService()
          .getEntriesByDateRange(_startDate!, _endDate!);
      setState(() {
        _entryCount = entries.length;
        _isLoadingCount = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCount = false;
      });
    }
  }

  bool _validateDateRange() {
    final l10n = AppLocalizations.of(context)!;

    if (_startDate == null || _endDate == null) {
      setState(() {
        _validationError = l10n.selectDateRange;
      });
      return false;
    }

    // Check if start date is after end date
    if (_startDate!.isAfter(_endDate!)) {
      setState(() {
        _validationError = l10n.invalidDateRange;
      });
      return false;
    }

    // Check if dates are in the future
    final today = DateTime.now();
    if (_startDate!.isAfter(today) || _endDate!.isAfter(today)) {
      setState(() {
        _validationError = l10n.futureDateNotAllowed;
      });
      return false;
    }

    // Check if range is too large (> 365 days)
    final daysDifference = _endDate!.difference(_startDate!).inDays;
    if (daysDifference > 365) {
      setState(() {
        _validationError = l10n.rangeTooLarge;
      });
      return false;
    }

    setState(() {
      _validationError = null;
    });
    return true;
  }

  Future<void> _selectDateRange() async {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      helpText: l10n.selectDateRange,
      cancelText: l10n.cancel,
      confirmText: l10n.ok,
      saveText: l10n.ok,
      fieldStartLabelText: l10n.startDate,
      fieldEndLabelText: l10n.endDate,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadEntryCount();
      _validateDateRange();
    }
  }

  Future<void> _performExport() async {
    final l10n = AppLocalizations.of(context)!;

    // Validate date range
    if (!_validateDateRange()) {
      return;
    }

    // Check if there are entries
    if (_entryCount == 0) {
      final shouldExport = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.noDataToExport),
          content: Text(l10n.noEntriesInRange),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.export),
            ),
          ],
        ),
      );

      if (shouldExport != true) {
        return;
      }
    }

    final exportService = ExportService();
    BuildContext? dialogContext;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(l10n.exportingData),
            ],
          ),
        );
      },
    );

    try {
      if (_selectedFormat == ExportFormat.csv) {
        await exportService.exportDiaryEntriesToCSV(
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await exportService.exportDiaryEntriesToJSON(
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      // Close loading dialog
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }

      // Show error message
      if (mounted) {
        String errorMessage = l10n.exportError;
        if (e.toString().contains('No diary entries')) {
          errorMessage = l10n.noDataToExport;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(l10n.exportScreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              l10n.exportScreenDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Date Range Section
            Text(
              l10n.selectDateRange,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: InkWell(
                onTap: _selectDateRange,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l10n.startDate,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Text(' - '),
                                Text(
                                  l10n.endDate,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (_startDate != null && _endDate != null)
                              Text(
                                '${DateFormat('MMM d, yyyy').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Text(
                                l10n.selectDateRange,
                                style: theme.textTheme.titleMedium,
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),

            // Entry count
            if (_isLoadingCount)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.searching,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else if (_entryCount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.entriesFound(_entryCount!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _entryCount! > 0
                        ? theme.colorScheme.primary
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Validation error
            if (_validationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Export Format Section
            Text(
              l10n.exportFormat,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  RadioListTile<ExportFormat>(
                    value: ExportFormat.csv,
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFormat = value;
                        });
                      }
                    },
                    title: Text(l10n.csvFormat),
                    secondary: const Icon(Icons.table_chart),
                  ),
                  const Divider(height: 1),
                  RadioListTile<ExportFormat>(
                    value: ExportFormat.json,
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFormat = value;
                        });
                      }
                    },
                    title: Text(l10n.jsonFormat),
                    secondary: const Icon(Icons.code),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Export Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _performExport,
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.export),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

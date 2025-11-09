import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/custom_colors.dart';
import '../widgets/branded_app_bar.dart';
import '../services/diary_provider.dart';
import '../services/settings_provider.dart';
import '../services/export_service.dart';
import 'local_products_list_screen.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: BrandedAppBar(
        title: l10n.settings,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.myProducts),
          _buildMyProductsOption(context),
          const Divider(),
          _buildSectionHeader(l10n.appearance),
          _buildLanguageOption(context),
          _buildThemeOption(context),
          const Divider(),
          _buildSectionHeader(l10n.dataManagement),
          _buildExportDataOption(context),
          _buildClearCacheOption(context),
          const Divider(),
          _buildSectionHeader(l10n.about),
          _buildAboutOption(context),
          _buildOFFAttribution(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildMyProductsOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.inventory_2, color: context.customColors.infoColor),
      title: Text(l10n.myProducts),
      subtitle: Text(l10n.manageYourCustomProducts),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LocalProductsListScreen(),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.language, color: context.customColors.infoColor),
      title: Text(l10n.language),
      subtitle: Text(_getLanguageSubtitle(context)),
      onTap: () => _showLanguageDialog(context),
    );
  }

  Widget _buildThemeOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.palette, color: context.customColors.themeColor),
      title: Text(l10n.theme),
      subtitle: Text(_getThemeSubtitle(context)),
      onTap: () => _showThemeDialog(context),
    );
  }

  Widget _buildExportDataOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.upload_file, color: context.customColors.exportColor),
      title: Text(l10n.exportDiaryEntries),
      subtitle: Text(l10n.exportDiaryEntriesDescription),
      onTap: () => _handleExportDiary(context),
    );
  }

  Widget _buildClearCacheOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.delete_sweep, color: context.customColors.warningColor),
      title: Text(l10n.clearFrequentProductsCache),
      subtitle: Text(l10n.clearFrequentProductsDescription),
      onTap: () => _showClearCacheDialog(context),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(
          l10n.clearCacheConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final provider =
                  Provider.of<DiaryProvider>(context, listen: false);
              await provider.clearFrequentProductsCache();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.cacheCleared),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: context.customColors.warningColor),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final version = _packageInfo != null
        ? 'v${_packageInfo!.version}'
        : l10n.loading;

    return ListTile(
      leading: Icon(Icons.info_outline, color: context.customColors.infoColor),
      title: Text(l10n.appVersion),
      subtitle: Text(version),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: l10n.appTitle,
          applicationVersion: _packageInfo?.version ?? '',
          applicationIcon: Icon(Icons.restaurant,
              size: 48, color: Theme.of(context).colorScheme.primary),
          children: [
            Text(
              l10n.appDescription,
            ),
          ],
        );
      },
    );
  }

  Widget _buildOFFAttribution(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.public, color: Theme.of(context).colorScheme.primary),
      title: Text(l10n.openFoodFacts),
      subtitle: Text(l10n.openFoodFactsAttribution),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.openFoodFacts),
            content: Text(
              l10n.openFoodFactsDescription +
                  '\n\n'
                      'Visit: https://world.openfoodfacts.org',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Provider.of<SettingsProvider>(context).locale;
    if (locale == null) {
      return l10n.systemDefault;
    }
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'ru':
        return 'Русский';
      case 'pl':
        return 'Polski';
      case 'be':
        return 'Беларуская';
      default:
        return locale.languageCode;
    }
  }

  String _getThemeSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = Provider.of<SettingsProvider>(context).themeMode;
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
      default:
        return l10n.systemDefault;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseLanguage),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale?>(
                title: Text(l10n.systemDefault),
                value: null,
                groupValue: settingsProvider.locale,
                onChanged: (value) {
                  settingsProvider.setLocale(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Locale?>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: settingsProvider.locale,
                onChanged: (value) {
                  settingsProvider.setLocale(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Locale?>(
                title: const Text('Español'),
                value: const Locale('es'),
                groupValue: settingsProvider.locale,
                onChanged: (value) {
                  settingsProvider.setLocale(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Locale?>(
                title: const Text('Русский'),
                value: const Locale('ru'),
                groupValue: settingsProvider.locale,
                onChanged: (value) {
                  settingsProvider.setLocale(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Locale?>(
                title: const Text('Polski'),
                value: const Locale('pl'),
                groupValue: settingsProvider.locale,
                onChanged: (value) {
                  settingsProvider.setLocale(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Locale?>(
                title: const Text('Беларуская'),
                value: const Locale('be'),
                groupValue: settingsProvider.locale,
                onChanged: (value) {
                  settingsProvider.setLocale(value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightTheme),
              value: ThemeMode.light,
              groupValue: settingsProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setThemeMode(value);
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkTheme),
              value: ThemeMode.dark,
              groupValue: settingsProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setThemeMode(value);
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemDefault),
              value: ThemeMode.system,
              groupValue: settingsProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setThemeMode(value);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExportDiary(BuildContext context) async {
    // Show date range selection dialog
    await _showExportOptionsDialog(context);
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
                _performExport(context, null, null);
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
                _performExport(context, startDate, endDate);
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
                _performExport(context, startDate, endDate);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performExport(
    BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final l10n = AppLocalizations.of(context)!;
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
      await exportService.exportDiaryEntriesToCSV(
        startDate: startDate,
        endDate: endDate,
      );

      // Close loading dialog
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }

      // Show error message
      if (context.mounted) {
        String errorMessage = l10n.exportError;
        if (e.toString().contains('No diary entries')) {
          errorMessage = l10n.noDataToExport;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: context.customColors.dangerColor,
          ),
        );
      }
    }
  }
}

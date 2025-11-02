import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/diary_provider.dart';
import '../services/settings_provider.dart';
import 'local_products_list_screen.dart';
import '../config/decorations.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.green,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.myProducts),
          _buildMyProductsOption(context),
          const Divider(),
          _buildSectionHeader(l10n.appearance),
          _buildThemeOption(context),
          const Divider(),
          _buildSectionHeader(l10n.dataManagement),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMyProductsOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.inventory_2, color: Colors.blue),
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

  Widget _buildThemeOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.palette, color: Colors.purple),
      title: Text(l10n.theme),
      subtitle: Text(_getThemeSubtitle(context)),
      onTap: () => _showThemeDialog(context),
    );
  }

  Widget _buildClearCacheOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.delete_sweep, color: Colors.orange),
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
              final provider = Provider.of<DiaryProvider>(context, listen: false);
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
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.blue),
      title: Text(l10n.appVersion),
      subtitle: Text(l10n.appVersionNumber),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: l10n.appTitle,
          applicationVersion: '1.0.0',
          applicationIcon: Icon(Icons.restaurant, size: 48, color: AppColors.green),
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
      leading: Icon(Icons.public, color: AppColors.green),
      title: Text(l10n.openFoodFacts),
      subtitle: Text(l10n.openFoodFactsAttribution),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.openFoodFacts),
            content: Text(
              l10n.openFoodFactsDescription + '\n\n'
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

  void _showThemeDialog(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
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
}

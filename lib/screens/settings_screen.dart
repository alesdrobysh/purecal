import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/custom_colors.dart';
import '../widgets/branded_app_bar.dart';
import '../services/settings_provider.dart';
import 'local_products_list_screen.dart';
import 'data_management_screen.dart';
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
          _buildDataManagementOption(context),
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

  Widget _buildDataManagementOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.storage, color: context.customColors.infoColor),
      title: Text(l10n.dataManagement),
      subtitle: Text(l10n.manageDataExportImport),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DataManagementScreen(),
          ),
        );
      },
    );
  }


  Widget _buildAboutOption(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final version =
        _packageInfo != null ? 'v${_packageInfo!.version}' : l10n.loading;

    return ListTile(
      leading: Icon(Icons.info_outline, color: context.customColors.infoColor),
      title: Text(l10n.appVersion),
      subtitle: Text(version),
      enabled: _packageInfo != null,
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
              '${l10n.openFoodFactsDescription}\n\nVisit: https://world.openfoodfacts.org',
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
          child: RadioGroup<Locale?>(
            groupValue: settingsProvider.locale,
            onChanged: (value) {
              settingsProvider.setLocale(value);
              Navigator.pop(context);
            },
            child: Column(
              children: [
                RadioListTile<Locale?>(
                    value: null, title: Text(l10n.systemDefault)),
                const RadioListTile<Locale?>(
                    value: Locale('en'), title: Text('English')),
                const RadioListTile<Locale?>(
                    value: Locale('es'), title: Text('Español')),
                const RadioListTile<Locale?>(
                    value: Locale('ru'), title: Text('Русский')),
                const RadioListTile<Locale?>(
                    value: Locale('be'), title: Text('Беларуская')),
                const RadioListTile<Locale?>(
                    value: Locale('pl'), title: Text('Polski')),
              ],
            ),
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
        content: RadioGroup<ThemeMode>(
          groupValue: settingsProvider.themeMode,
          onChanged: (value) {
            if (value != null) {
              settingsProvider.setThemeMode(value);
            }
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                  value: ThemeMode.light, title: Text(l10n.lightTheme)),
              RadioListTile<ThemeMode>(
                  value: ThemeMode.dark, title: Text(l10n.darkTheme)),
              RadioListTile<ThemeMode>(
                  value: ThemeMode.system, title: Text(l10n.systemDefault)),
            ],
          ),
        ),
      ),
    );
  }

}

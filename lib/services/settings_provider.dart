import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  static const String _localeKey = 'locale';

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  SettingsProvider() {
    // Settings are loaded asynchronously in loadInitialSettings
  }

  Future<void> loadInitialSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    // Load locale
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null && localeCode.isNotEmpty) {
      _locale = Locale(localeCode);
    }
    // No notifyListeners here, as it's called before runApp
  }

  void setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  void setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
    notifyListeners();
  }
}

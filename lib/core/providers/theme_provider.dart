import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.light;
  bool _initialized = false;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _initialized;

  Future<void> _loadThemeMode() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedThemeMode = _prefs.getString(_themeKey);
      if (savedThemeMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedThemeMode,
          orElse: () => ThemeMode.light,
        );
      }
    } catch (e) {
      // If there's an error, fallback to light theme
      _themeMode = ThemeMode.light;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    try {
      await _prefs.setString(_themeKey, _themeMode.toString());
    } catch (e) {
      // Handle error if needed
    }
    notifyListeners();
  }
}

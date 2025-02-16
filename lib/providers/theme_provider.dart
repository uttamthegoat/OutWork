import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String THEME_KEY = 'theme_key';
  SharedPreferences? _prefs;
  bool _isDarkMode = true; // Set initial default to true for dark mode
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(THEME_KEY) ?? true;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _prefs = await SharedPreferences.getInstance();
    await _prefs?.setBool(THEME_KEY, _isDarkMode);
    notifyListeners();
  }
}

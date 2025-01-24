import 'package:flutter/material.dart';
import 'black_white_theme.dart';
import 'white_black_theme.dart';

class AppThemes {
  static final Map<ThemeMode, ThemeData> _themes = {
    ThemeMode.dark: BlackWhiteTheme.darkTheme,
    ThemeMode.light: WhiteBlackTheme.lightTheme,
  };

  // Light theme getter
  static ThemeData get lightTheme => _themes[ThemeMode.light]!;

  // Dark theme getter
  static ThemeData get darkTheme => _themes[ThemeMode.dark]!;
}

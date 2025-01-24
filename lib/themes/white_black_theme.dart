import 'package:flutter/material.dart';

class WhiteBlackTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          background: Colors.white,
          surface: Colors.white,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          onBackground: Colors.black,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE6E6FA),
          foregroundColor: Colors.black,
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.black,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          elevation: 2,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
}

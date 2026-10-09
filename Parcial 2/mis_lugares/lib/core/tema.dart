import 'package:flutter/material.dart';

class AppTema {
  static const _semilla = Colors.teal;

  static ThemeData _base(Brightness brillo) {
    final esquema = ColorScheme.fromSeed(seedColor: _semilla, brightness: brillo);
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static final ThemeData claro = _base(Brightness.light);
  static final ThemeData oscuro = _base(Brightness.dark);
}
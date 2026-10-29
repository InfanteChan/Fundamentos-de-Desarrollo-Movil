import 'package:flutter/material.dart';
import 'package:pizzeria/theme/app_colors.dart';
import 'package:pizzeria/theme/app_palette.dart';

class AppTheme {
      static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppPalette.light.background,
        extensions: const [AppPalette.light],
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppPalette.light.cardBackground,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppPalette.dark.background,
        extensions: const [AppPalette.dark],
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          surface: AppPalette.dark.cardBackground,
        ),
      );
}


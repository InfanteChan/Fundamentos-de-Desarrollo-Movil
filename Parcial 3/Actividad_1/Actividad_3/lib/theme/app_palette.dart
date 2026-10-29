import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color cardBackground;
  final Color inputBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;
  final Color border;
  final Color primaryLight;

  const AppPalette({
    required this.background,
    required this.cardBackground,
    required this.inputBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
    required this.border,
    required this.primaryLight,
  });

  static const light = AppPalette(
    background: Color(0xFFFAF7F5),
    cardBackground: Colors.white,
    inputBackground: Color(0xFFF4EFEA),
    textPrimary: Color(0xFF1E1E1E),
    textSecondary: Color(0xFF757575),
    textLight: Color(0xFF9E9E9E),
    border: Color(0xFFE8E0D9),
    primaryLight: Color(0xFFFDE8E8),
  );

  static const dark = AppPalette(
    background: Color(0xFF121212),
    cardBackground: Color(0xFF1E1E1E),
    inputBackground: Color(0xFF2A2A2A),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xFFB0B0B0),
    textLight: Color(0xFF8A8A8A),
    border: Color(0xFF3A3A3A),
    primaryLight: Color(0xFF3A1F1F),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? cardBackground,
    Color? inputBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textLight,
    Color? border,
    Color? primaryLight,
  }) {
    return AppPalette(
      background: background ?? this.background,
      cardBackground: cardBackground ?? this.cardBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textLight: textLight ?? this.textLight,
      border: border ?? this.border,
      primaryLight: primaryLight ?? this.primaryLight,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      border: Color.lerp(border, other.border, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
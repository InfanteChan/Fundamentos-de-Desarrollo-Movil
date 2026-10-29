import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/theme/app_colors.dart';


class ThemeModeSwitch extends StatelessWidget {
  const ThemeModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final adaptive = AdaptiveTheme.of(context);

    return ValueListenableBuilder<AdaptiveThemeMode>(
      valueListenable: adaptive.modeChangeNotifier,
      builder: (context, mode, _) {
        return SwitchListTile(
          secondary: Icon(
            mode.isDark ? Icons.dark_mode : Icons.light_mode,
            color: AppColors.primary,
          ),
          title: Text(
            'Modo oscuro',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          value: mode.isDark,
          onChanged: (value) =>
              value ? adaptive.setDark() : adaptive.setLight(),
        );
      },
    );
  }
}
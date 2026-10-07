import 'package:flutter/material.dart';
import 'package:pizzeria/core/bootstrap/app_bootstrap.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/screens/splash_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class ErrorInitScreen extends StatelessWidget {
  const ErrorInitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 80, color: AppColors.bannerRed),
              const SizedBox(height: 20),
              const Text(
                'Error de Configuración',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No se pudo conectar con Supabase. Verifica tu archivo env.dev.json y ejecuta la app con --dart-define-from-file=env.dev.json.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: 'Reintentar',
                width: 200,
                onPressed: () async {
                  await AppBootstrap.init();
                  if (!context.mounted) return;
                  CustomNavigator.pushReplacementFade(
                      context, const SplashScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
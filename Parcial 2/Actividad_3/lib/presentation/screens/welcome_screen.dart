import 'package:flutter/material.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/screens/login_screen.dart';
import 'package:pizzeria/presentation/screens/register_screen.dart';
import 'package:pizzeria/presentation/screens/seller_register_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PizzApp',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&auto=format&fit=crop&q=80',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.inputBackground,
                          child: const Center(
                            child: Icon(Icons.local_pizza,
                                size: 100, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        const Text(
                          '¡Bienvenido a\nPizzApp!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Las mejores pizzas artesanales y pizzerías locales a la puerta de tu casa.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                        CustomButton(
                          text: 'Iniciar Sesión',
                          onPressed: () => CustomNavigator.pushFade(
                              context, const LoginScreen()),
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Crear Cuenta',
                          variant: ButtonVariant.outlined,
                          onPressed: () => CustomNavigator.pushFade(
                              context, const RegisterScreen()),
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          text: '¿Tienes una pizzería? Regístrate aquí',
                          variant: ButtonVariant.text,
                          textColor: AppColors.bannerRed,
                          onPressed: () => CustomNavigator.pushFade(
                              context, const SellerRegisterScreen()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
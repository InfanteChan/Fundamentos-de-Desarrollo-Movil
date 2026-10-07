//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/bootstrap/app_bootstrap.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/screens/error_init_screen.dart';
import 'package:pizzeria/presentation/screens/main_navigation_screen.dart';
import 'package:pizzeria/presentation/screens/seller/seller_dashboard_screen.dart';
import 'package:pizzeria/presentation/screens/welcome_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    if (!AppBootstrap.isReady) {
      CustomNavigator.pushReplacementFade(context, const ErrorInitScreen());
      return;
    }

    Widget destination = const WelcomeScreen();
    try {
      final profile = await ref.read(authProvider.future);
      if (profile != null) {
        destination = profile.isSeller
            ? const SellerDashboardScreen()
            : const MainNavigationScreen();
      }
    } catch (e) {
      debugPrint('Error al revisar la sesión: $e');
    }

    if (!mounted) return;
    CustomNavigator.pushAndRemoveUntilFade(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              PizzaLogo(size: 130),
              SizedBox(height: 24),
              Text(
                'PizzApp',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              Spacer(flex: 2),
              DashedOvenLoader(size: 70),
              SizedBox(height: 16),
              Text(
                'Preparando el Horno',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bannerRed,
                ),
              ),
              Spacer(flex: 3),
              Text(
                'Todos los derechos reservados @2026',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
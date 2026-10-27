import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/validators/form_validators.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/screens/main_navigation_screen.dart';
import 'package:pizzeria/presentation/screens/register_screen.dart';
import 'package:pizzeria/presentation/screens/seller/seller_dashboard_screen.dart';
import 'package:pizzeria/presentation/screens/seller_register_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _generalError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = FormValidators.email(_emailController.text);
      _passwordError = FormValidators.password(_passwordController.text);
      _generalError = null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    try {
      final profile = await ref.read(authProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;

      final Widget destination = profile.isSeller
          ? const SellerDashboardScreen()
          : const MainNavigationScreen();
      CustomNavigator.pushAndRemoveUntilFade(context, destination);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  const PizzaLogo(size: 80),
                  const SizedBox(height: 14),
                  const Text(
                    'PizzApp',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Inicia sesión para continuar tu antojo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bannerRed,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ErrorBanner(message: _generalError),
                  AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          label: 'Correo Electrónico',
                          hintText: 'correo@ejemplo.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) => setState(() => _emailError = null),
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hintText: 'Ingresa tu contraseña',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          errorText: _passwordError,
                          onChanged: (_) =>
                              setState(() => _passwordError = null),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Entrar a PizzApp',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta de comprador? ',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: () => CustomNavigator.pushFade(
                            context, const RegisterScreen()),
                        child: const Text(
                          'REGÍSTRATE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bannerRed,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => CustomNavigator.pushFade(
                        context, const SellerRegisterScreen()),
                    child: const Text(
                      '¿Tienes una pizzería? Regístrate como vendedor aquí',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
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

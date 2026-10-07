import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/validators/form_validators.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/screens/seller/seller_dashboard_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SellerRegisterScreen extends ConsumerStatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  ConsumerState<SellerRegisterScreen> createState() =>
      _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends ConsumerState<SellerRegisterScreen> {
  final _nameController = TextEditingController();
  final _restaurantController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _nameError;
  String? _restaurantError;
  String? _emailError;
  String? _passwordError;
  String? _generalError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _restaurantController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _nameError = FormValidators.requiredField(
          _nameController.text, 'Ingresa tu nombre completo');
      _restaurantError = FormValidators.requiredField(
          _restaurantController.text, 'Ingresa el nombre de tu pizzería');
      _emailError = FormValidators.email(_emailController.text);
      _passwordError = FormValidators.password(_passwordController.text);
      _generalError = null;
    });
    if (_nameError != null ||
        _restaurantError != null ||
        _emailError != null ||
        _passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signUpSeller(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            restaurantName: _restaurantController.text.trim(),
          );
      if (!mounted) return;
      CustomNavigator.pushAndRemoveUntilFade(
          context, const SellerDashboardScreen());
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  const PizzaLogo(size: 72),
                  const SizedBox(height: 12),
                  const Text(
                    'Portal de Vendedores',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Registra tu pizzería y gestiona tus pedidos en tiempo real',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ErrorBanner(message: _generalError),
                  AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          label: 'Nombre del Propietario / Encargado',
                          hintText: 'Ej. Marco Rossi',
                          prefixIcon: Icons.person_outline,
                          errorText: _nameError,
                          onChanged: (_) => setState(() => _nameError = null),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _restaurantController,
                          label: 'Nombre de la Pizzería',
                          hintText: 'Ej. Pizzería Bella Napoli',
                          prefixIcon: Icons.storefront_outlined,
                          errorText: _restaurantError,
                          onChanged: (_) =>
                              setState(() => _restaurantError = null),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Correo Electrónico',
                          hintText: 'negocio@pizzeria.com',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) => setState(() => _emailError = null),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          errorText: _passwordError,
                          onChanged: (_) =>
                              setState(() => _passwordError = null),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Registrar Mi Pizzería',
                          isLoading: _isLoading,
                          onPressed: _handleRegister,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';
import 'package:pizzeria/presentation/screens/welcome_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final restaurantAsync = ref.watch(sellerRestaurantProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Perfil de Vendedor', showBackButton: false),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.storefront,
                      size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Vendedor PizzApp',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'CUENTA VENDEDOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.store,
                        title: 'Pizzería',
                        subtitle: restaurantAsync.value?.name ?? 'No configurado',
                      ),
                      const Divider(height: 24),
                      const _InfoRow(
                        icon: Icons.security,
                        title: 'Seguridad',
                        subtitle: 'Protegido por Supabase Auth',
                      ),
                      const Divider(height: 24),
                      const _InfoRow(
                        icon: Icons.verified_user_outlined,
                        title: 'Estado del Negocio',
                        subtitle: 'Activo y Verificado',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Cerrar Sesión',
                  variant: ButtonVariant.outlined,
                  textColor: Colors.red,
                  backgroundColor: Colors.red,
                  icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (!context.mounted) return;
                    CustomNavigator.pushAndRemoveUntilFade(
                        context, const WelcomeScreen());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/screens/cart_screen.dart';
import 'package:pizzeria/presentation/screens/home_screen.dart';
import 'package:pizzeria/presentation/screens/menu_screen.dart';
import 'package:pizzeria/presentation/screens/welcome_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex = widget.initialIndex;

  void _goToMenu() => setState(() => _currentIndex = 1);

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);

    final screens = [
      HomeScreen(onNavigateToMenu: _goToMenu),
      MenuScreen(onNavigateToMenu: _goToMenu),
      const _ComingSoonTab(title: 'Pedidos', icon: Icons.shopping_bag_outlined),
      const _ComingSoonTab(title: 'Mapa', icon: Icons.map_outlined),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: cartCount > 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                'Carrito ($cartCount)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => CustomNavigator.pushFade(
                context,
                CartScreen(onAddMoreProducts: _goToMenu),
              ),
            )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// Marcador temporal hasta construir estas pantallas
class _ComingSoonTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: title, showBackButton: false),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textLight),
            const SizedBox(height: 12),
            const Text('Próximamente',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// Perfil básico con cierre de sesión (se completará más adelante)
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Perfil', showBackButton: false),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PizzaLogo(size: 80),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(user?.email ?? '',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Cerrar sesión',
              width: 200,
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
    );
  }
}
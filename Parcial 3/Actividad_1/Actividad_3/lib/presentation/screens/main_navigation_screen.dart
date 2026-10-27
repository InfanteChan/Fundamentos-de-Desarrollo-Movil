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
import 'package:pizzeria/presentation/screens/buyer_orders_screen.dart';
import 'package:pizzeria/presentation/screens/map_screen.dart';

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
      const BuyerOrdersScreen(),
       const MapScreen(),
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
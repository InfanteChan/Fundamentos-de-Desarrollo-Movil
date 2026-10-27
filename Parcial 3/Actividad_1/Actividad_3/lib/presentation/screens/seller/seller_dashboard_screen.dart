import 'package:flutter/material.dart';
import 'package:pizzeria/presentation/screens/seller/seller_orders_screen.dart';
import 'package:pizzeria/presentation/screens/seller/seller_profile_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SellerDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const SellerDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  late int _currentIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    const screens = [
      SellerOrdersScreen(),
      _ComingSoonTab(title: 'Mis Pizzas', icon: Icons.local_pizza_outlined),
      _ComingSoonTab(title: 'Mi Local', icon: Icons.storefront_outlined),
      SellerProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.receipt_long_outlined, Icons.receipt_long, 'Pedidos'),
                _navItem(1, Icons.local_pizza_outlined, Icons.local_pizza, 'Pizzas'),
                _navItem(2, Icons.storefront_outlined, Icons.storefront, 'Mi Local'),
                _navItem(3, Icons.person_outline, Icons.person, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Marcador temporal hasta construir estas pantallas (9B y 9C)
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
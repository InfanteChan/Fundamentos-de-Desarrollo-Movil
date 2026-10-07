import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/ui/cart_actions.dart';
import 'package:pizzeria/presentation/providers/pizza_provider.dart';
import 'package:pizzeria/presentation/screens/pizza_detail_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToMenu;

  const HomeScreen({super.key, this.onNavigateToMenu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pizzasAsync = ref.watch(pizzasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'PizzApp',
        showBackButton: false,
        trailing: CartButtonBadge(onAddMoreProducts: onNavigateToMenu),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PromoBanner(onOrderNow: onNavigateToMenu),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pizzas Populares',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: onNavigateToMenu,
                      child: const Text(
                        'Ver todas',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.bannerRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                pizzasAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: DashedOvenLoader(),
                    ),
                  ),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (pizzas) {
                    if (pizzas.isEmpty) return const _EmptyCatalog();

                    return Column(
                      children: [
                        for (final pizza in pizzas.take(3))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PizzaPopularCard(
                              pizza: pizza,
                              onTap: () => CustomNavigator.pushFade(
                                context,
                                PizzaDetailScreen(pizza: pizza),
                              ),
                              onAddToCart: () =>
                                  addToCartWithFeedback(context, ref, pizza),
                            ),
                          ),
                      ],
                    );
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

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.restaurant_menu, size: 48, color: AppColors.textLight),
          SizedBox(height: 10),
          Text(
            'Aún no hay pizzas disponibles en el catálogo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Los vendedores agregarán productos pronto.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
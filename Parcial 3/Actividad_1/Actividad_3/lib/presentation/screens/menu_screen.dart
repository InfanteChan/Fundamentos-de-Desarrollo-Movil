import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/ui/cart_actions.dart';
import 'package:pizzeria/presentation/providers/pizza_provider.dart';
import 'package:pizzeria/presentation/screens/pizza_detail_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class MenuScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToMenu;

  const MenuScreen({super.key, this.onNavigateToMenu});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _category = 'Todas';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final pizzasAsync = ref.watch(pizzasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'PizzApp',
        showBackButton: false,
        trailing: CartButtonBadge(onAddMoreProducts: widget.onNavigateToMenu),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Nuestras Pizzas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Artesanales, frescas y listas para ti',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Buscar pizzas...',
                      hintStyle:
                          TextStyle(color: AppColors.textLight, fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          color: AppColors.textLight, size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CategoryFilterChips(
                  selectedCategory: _category,
                  onCategorySelected: (c) => setState(() => _category = c),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: pizzasAsync.when(
                    loading: () => const Center(child: DashedOvenLoader()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (allPizzas) {
                      final pizzas = allPizzas.where((pizza) {
                        final matchesCategory = _category == 'Todas' ||
                            pizza.category.toLowerCase() ==
                                _category.toLowerCase();
                        final matchesSearch = pizza.name
                            .toLowerCase()
                            .contains(_query.toLowerCase());
                        return matchesCategory && matchesSearch;
                      }).toList();

                      if (pizzas.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off,
                                  size: 60, color: AppColors.textLight),
                              SizedBox(height: 12),
                              Text(
                                'No se encontraron pizzas con ese criterio',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: pizzas.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pizza = pizzas[index];
                          return PizzaListItem(
                            pizza: pizza,
                            onTap: () => CustomNavigator.pushFade(
                              context,
                              PizzaDetailScreen(pizza: pizza),
                            ),
                            onAddToCart: () =>
                                addToCartWithFeedback(context, ref, pizza),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
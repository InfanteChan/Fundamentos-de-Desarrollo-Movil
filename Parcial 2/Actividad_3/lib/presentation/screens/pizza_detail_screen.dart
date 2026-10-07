import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/ui/cart_actions.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class PizzaDetailScreen extends ConsumerStatefulWidget {
  final PizzaModel pizza;

  const PizzaDetailScreen({super.key, required this.pizza});

  @override
  ConsumerState<PizzaDetailScreen> createState() => _PizzaDetailScreenState();
}

class _PizzaDetailScreenState extends ConsumerState<PizzaDetailScreen> {
  late String _size =
      widget.pizza.sizes.isNotEmpty ? widget.pizza.sizes.first : 'Mediana';
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final pizza = widget.pizza;
    final total = pizza.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: '',
           trailing: Row(
     mainAxisSize: MainAxisSize.min,
     children: [
       IconButton(
         icon: Icon(
           _isFavorite ? Icons.favorite : Icons.favorite_border,
           color: _isFavorite ? AppColors.primary : AppColors.textPrimary,
         ),
         onPressed: () => setState(() => _isFavorite = !_isFavorite),
       ),
       const CartButtonBadge(),
     ],
   ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 260,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            pizza.imageUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 800,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.inputBackground,
                              child: const Icon(Icons.local_pizza,
                                  size: 100, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              pizza.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '\$${pizza.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rate_rounded,
                              color: AppColors.star, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${pizza.rating} (${pizza.reviewsCount} reseñas)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        pizza.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _RestaurantCard(pizza: pizza),
                      const SizedBox(height: 20),
                      const Text(
                        'Selecciona el Tamaño',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final size in pizza.sizes)
                            _SizeChip(
                              label: size,
                              selected: size == _size,
                              onTap: () => setState(() => _size = size),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      QuantitySelector(
                        quantity: _quantity,
                        isLarge: true,
                        onChanged: (q) => setState(() => _quantity = q),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomButton(
                          text: 'Agregar  •  \$${total.toStringAsFixed(2)}',
                             onPressed: () => addToCartWithFeedback(
                            context,
                             ref,
                            pizza,
                             quantity: _quantity,
                            size: _size,
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final PizzaModel pizza;

  const _RestaurantCard({required this.pizza});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pizza.restaurantName ?? 'Pizzería',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pizza.restaurantAddress ?? 'Dirección no disponible',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
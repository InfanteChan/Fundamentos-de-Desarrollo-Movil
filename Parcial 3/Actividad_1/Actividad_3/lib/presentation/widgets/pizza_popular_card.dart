import 'package:flutter/material.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/theme/app_colors.dart';

class PizzaPopularCard extends StatelessWidget {
  final PizzaModel pizza;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const PizzaPopularCard({
    super.key,
    required this.pizza,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 150,
                width: double.infinity,
                color: AppColors.inputBackground,
                child: Image.network(
                  pizza.imageUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 600,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.local_pizza,
                        size: 60, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              pizza.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pizza.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$ ${pizza.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/theme/app_colors.dart';

class PizzaListItem extends StatelessWidget {
  final PizzaModel pizza;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const PizzaListItem({
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: ClipOval(
                child: Image.network(
                  pizza.imageUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 200,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.inputBackground,
                    child: const Icon(Icons.local_pizza,
                        color: AppColors.primary, size: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pizza.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${pizza.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.add, color: Colors.white, size: 18),
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
import 'package:flutter/material.dart';
import 'package:pizzeria/models/cart_item_model.dart';
import 'package:pizzeria/presentation/widgets/quantity_selector.dart';
import 'package:pizzeria/theme/app_colors.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            height: 65,
            child: ClipOval(
              child: Image.network(
                item.pizza.imageUrl,
                fit: BoxFit.cover,
                cacheWidth: 200,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.inputBackground,
                  child:
                      const Icon(Icons.local_pizza, color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.pizza.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.delete_outline,
                            size: 20, color: AppColors.textLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Tamaño: ${item.size}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$ ${item.pizza.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    QuantitySelector(
                      quantity: item.quantity,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
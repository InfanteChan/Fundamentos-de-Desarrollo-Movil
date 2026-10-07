import 'package:flutter/material.dart';
import 'package:pizzeria/theme/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final bool isLarge;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isLarge ? 20.0 : 14.0;
    final gap = isLarge ? 16.0 : 8.0;

    return Container(
      padding: isLarge
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(isLarge ? 24 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (quantity > 1) onChanged(quantity - 1);
            },
            child: Icon(Icons.remove,
                size: iconSize, color: AppColors.textPrimary),
          ),
          SizedBox(width: gap),
          Text(
            isLarge ? quantity.toString().padLeft(2, '0') : '$quantity',
            style: TextStyle(
              fontSize: isLarge ? 16 : 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: gap),
          GestureDetector(
            onTap: () => onChanged(quantity + 1),
            child:
                Icon(Icons.add, size: iconSize, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
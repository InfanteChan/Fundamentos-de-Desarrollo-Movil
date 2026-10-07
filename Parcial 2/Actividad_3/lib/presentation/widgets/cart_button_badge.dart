import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/screens/cart_screen.dart';
import 'package:pizzeria/theme/app_colors.dart';

class CartButtonBadge extends ConsumerWidget {
  final VoidCallback? onAddMoreProducts;

  const CartButtonBadge({super.key, this.onAddMoreProducts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);

    return InkWell(
      onTap: () => CustomNavigator.pushFade(
        context,
        CartScreen(onAddMoreProducts: onAddMoreProducts),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: count > 0 ? AppColors.primary : AppColors.border,
            width: count > 0 ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: count > 0 ? AppColors.primary : AppColors.textPrimary,
              size: 22,
            ),
            if (count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.bannerRed,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
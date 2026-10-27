import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/ui/app_snackbar.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/screens/checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  final VoidCallback? onAddMoreProducts;

  const CartScreen({super.key, this.onAddMoreProducts});

  Future<void> _safe(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, 'No se pudo actualizar el carrito');
      }
    }
  }

  // Cierra el carrito y luego va al menú
  void _addMore(BuildContext context) {
    Navigator.of(context).pop();
    onAddMoreProducts?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final deliveryFee = ref.watch(cartDeliveryFeeProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Carrito'),
      body: items.isEmpty
          ? _EmptyCart(
              onExplore:
                  onAddMoreProducts == null ? null : () => _addMore(context),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tu pedido',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count items',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CartItemCard(
                            item: item,
                            onQuantityChanged: (q) => _safe(context,
                                () => notifier.updateQuantity(item.id, q)),
                            onRemove: () => _safe(
                                context, () => notifier.removeItem(item.id)),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (onAddMoreProducts != null)
                        GestureDetector(
                          onTap: () => _addMore(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.border, width: 1.2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline,
                                    color: AppColors.textSecondary, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Agregar más productos',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      OrderSummaryCard(
                        subtotal: subtotal,
                        deliveryFee: deliveryFee,
                        onCheckout: () => CustomNavigator.pushFade(
                            context, const CheckoutScreen()),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback? onExplore;

  const _EmptyCart({this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_shopping_cart_outlined,
                size: 80, color: AppColors.textLight),
            const SizedBox(height: 16),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega deliciosas pizzas del menú para comenzar tu pedido.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            if (onExplore != null)
              CustomButton(text: 'Explorar Menú', width: 200, onPressed: onExplore),
          ],
        ),
      ),
    );
  }
}
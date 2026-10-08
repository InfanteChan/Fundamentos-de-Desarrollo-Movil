import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/ui/app_snackbar.dart';
import 'package:pizzeria/models/cart_item_model.dart';
import 'package:pizzeria/models/order_model.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/providers/order_provider.dart';
import 'package:pizzeria/presentation/screens/main_navigation_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:pizzeria/presentation/providers/location_provider.dart';
import 'package:pizzeria/presentation/screens/map_location_picker_screen.dart';

class _PaymentOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _PaymentOption(this.id, this.title, this.subtitle, this.icon);
}

const _paymentOptions = [
  _PaymentOption('Efectivo', 'Efectivo contra entrega',
      'Pagas al recibir tu pedido en puerta', Icons.payments_outlined),
  _PaymentOption('Tarjeta', 'Tarjeta de Crédito / Débito',
      'Visa, Mastercard, AMEX', Icons.credit_card_outlined),
  _PaymentOption('Transferencia', 'Transferencia SPEI',
      'Envía comprobante al repartidor', Icons.account_balance_outlined),
];

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _addressError;
  String _payment = 'Efectivo';
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

     Future<void> _pickFromMap() async {
     var initial = const LatLng(19.432608, -99.133209);
     try {
       initial = await ref.read(userLocationProvider.future);
     } catch (_) {}

     if (!mounted) return;
     final result = await CustomNavigator.pushFade<MapLocationResult>(
       context,
       MapLocationPickerScreen(
         initialPosition: initial,
         title: 'Dirección de Entrega',
       ),
     );

     if (result != null && mounted) {
       setState(() {
         _addressController.text =
             'Ubicación en el mapa (${result.position.latitude.toStringAsFixed(4)}, ${result.position.longitude.toStringAsFixed(4)})';
         _addressError = null;
       });
     }
   }

  Future<void> _placeOrder() async {
    final cartNotifier = ref.read(cartProvider.notifier);
    final items = ref.read(cartProvider);
    final user = ref.read(authProvider).value;

    if (items.isEmpty) {
      showAppSnackBar(context, 'Tu carrito está vacío');
      return;
    }
    if (user == null) {
      showAppSnackBar(context, 'Inicia sesión para hacer tu pedido');
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() => _addressError = 'Ingresa la dirección completa de entrega');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Un pedido por cada pizzería
      final groups = <String, List<CartItemModel>>{};
      for (final item in items) {
        final restaurantId = item.pizza.restaurantId;
        if (restaurantId == null || restaurantId.isEmpty) {
          throw Exception('Una pizza del carrito ya no está disponible');
        }
        groups.putIfAbsent(restaurantId, () => []).add(item);
      }

      final notes = _notesController.text.trim();

      for (final entry in groups.entries) {
        final subtotal =
            entry.value.fold(0.0, (sum, i) => sum + i.totalPrice);

        final order = OrderModel(
          id: '',
          buyerId: user.id,
          restaurantId: entry.key,
          totalAmount: subtotal + kDeliveryFee,
          deliveryAddress: address,
          paymentMethod: _payment,
          notes: notes.isEmpty ? null : notes,
          createdAt: DateTime.now(),
          items: [
            for (final i in entry.value)
              OrderItemModel(
                pizzaId: i.pizza.id,
                pizzaName: i.pizza.name,
                quantity: i.quantity,
                unitPrice: i.pizza.price,
                size: i.size,
              ),
          ],
        );

        await ref.read(buyerOrdersProvider.notifier).placeOrder(order);

        // Saca del carrito lo que ya se pidió
        for (final i in entry.value) {
          await cartNotifier.removeItem(i.id);
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final message = e.toString().replaceAll('Exception: ', '');
      showAppSnackBar(context, 'No se pudo procesar el pedido: $message');
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 12),
            Text(
              '¡Pedido Confirmado!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: const Text(
          'Tu pedido fue enviado a la pizzería y ya está siendo procesado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          CustomButton(
            text: 'Ver Mis Pedidos',
            width: 200,
            onPressed: () {
              Navigator.pop(ctx);
              CustomNavigator.pushAndRemoveUntilFade(
                context,
                const MainNavigationScreen(initialIndex: 2),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final deliveryFee = ref.watch(cartDeliveryFeeProvider);
    final total = ref.watch(cartTotalProvider);
    final restaurantCount =
        items.map((i) => i.pizza.restaurantId).toSet().length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Finalizar Compra'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dirección de Entrega',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _addressController,
                  label: 'Dirección completa',
                  hintText: 'Calle, número exterior/interior, colonia y CP',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                  errorText: _addressError,
                  onChanged: (_) => setState(() => _addressError = null),
                ),
                   Align(
     alignment: Alignment.centerRight,
     child: TextButton.icon(
       onPressed: _pickFromMap,
       icon: const Icon(Icons.map_outlined,
           size: 18, color: AppColors.primary),
       label: const Text(
         'Seleccionar en el mapa',
         style: TextStyle(
           color: AppColors.primary,
           fontWeight: FontWeight.w600,
           fontSize: 13,
         ),
       ),
     ),
   ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notesController,
                  label: 'Instrucciones para el repartidor (Opcional)',
                  hintText: 'Ej. Timbre 3B o dejar en caseta',
                  prefixIcon: Icons.notes_outlined,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Método de Pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                for (final option in _paymentOptions)
                  _PaymentTile(
                    option: option,
                    selected: _payment == option.id,
                    onTap: () => setState(() => _payment = option.id),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen del Pedido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final item in items)
                        _SummaryRow(
                          '${item.quantity}x ${item.pizza.name} (${item.size})',
                          item.totalPrice,
                        ),
                      const Divider(height: 24),
                      _SummaryRow('Subtotal', subtotal, muted: true),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        restaurantCount > 1
                            ? 'Envío ($restaurantCount pizzerías)'
                            : 'Envío a domicilio',
                        deliveryFee,
                        muted: true,
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a Pagar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Confirmar y Pagar \$${total.toStringAsFixed(2)}',
                  isLoading: _isLoading,
                  onPressed: _placeOrder,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final _PaymentOption option;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(option.icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool muted;

  const _SummaryRow(this.label, this.amount, {this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: muted ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
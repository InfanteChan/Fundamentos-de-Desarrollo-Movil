import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/ui/app_snackbar.dart';
import 'package:pizzeria/models/order_model.dart';
import 'package:pizzeria/presentation/providers/order_provider.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

const _statusFilters = [
  ('todos', 'Todos'),
  ('pendiente', 'Pendientes'),
  ('en_preparacion', 'En Cocina'),
  ('en_camino', 'En Camino'),
  ('entregado', 'Entregados'),
  ('cancelado', 'Cancelados'),
];

const _statusOptions = [
  ('pendiente', 'Pendiente', Icons.timer_outlined, Colors.orange),
  ('en_preparacion', 'En Preparación / Horno', Icons.soup_kitchen_outlined, Colors.blue),
  ('en_camino', 'En Camino / Con Repartidor', Icons.delivery_dining_outlined, Colors.purple),
  ('entregado', 'Entregado con Éxito', Icons.check_circle_outline, Colors.green),
  ('cancelado', 'Cancelar Pedido', Icons.cancel_outlined, Colors.red),
];

Color _statusColor(String status) {
  for (final option in _statusOptions) {
    if (option.$1 == status) return option.$4;
  }
  return AppColors.textSecondary;
}

class SellerOrdersScreen extends ConsumerStatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  ConsumerState<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends ConsumerState<SellerOrdersScreen> {
  String _filter = 'todos';

  Future<void> _updateStatus(OrderModel order, String status) async {
    try {
      await ref.read(sellerOrdersProvider.notifier).updateStatus(order.id, status);
    } catch (e) {
      if (mounted) showAppSnackBar(context, 'No se pudo cambiar el estado');
    }
  }

  void _showStatusSheet(OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar Estado del Pedido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              for (final option in _statusOptions)
                ListTile(
                  leading: Icon(option.$3, color: option.$4),
                  title: Text(
                    option.$2,
                    style: TextStyle(
                      fontWeight: order.status == option.$1
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: order.status == option.$1
                          ? option.$4
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: order.status == option.$1
                      ? Icon(Icons.check, color: option.$4)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (order.status != option.$1) {
                      _updateStatus(order, option.$1);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Gestión de Pedidos', showBackButton: false),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _statusFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final (key, label) = _statusFilters[index];
                    final isSelected = _filter == key;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _filter = key),
                    );
                  },
                ),
              ),
              Expanded(
                child: ordersAsync.when(
                  loading: () => const Center(child: DashedOvenLoader()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (orders) {
                    final filtered = _filter == 'todos'
                        ? orders
                        : orders.where((o) => o.status == _filter).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 70, color: AppColors.textLight),
                              SizedBox(height: 16),
                              Text(
                                'No hay pedidos en esta sección',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(sellerOrdersProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) => _SellerOrderCard(
                          order: filtered[index],
                          onChangeStatus: () => _showStatusSheet(filtered[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onChangeStatus;

  const _SellerOrderCard({required this.order, required this.onChangeStatus});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    final shortId = order.id.length > 8 ? order.id.substring(0, 8) : order.id;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido #$shortId',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: onChangeStatus,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.statusDisplay,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: color, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (order.buyerName != null) ...[
            _InfoLine(Icons.person_outline, 'Cliente: ${order.buyerName}', bold: true),
            const SizedBox(height: 6),
          ],
          _InfoLine(Icons.location_on_outlined, order.deliveryAddress),
          const SizedBox(height: 6),
          _InfoLine(Icons.payment_outlined, 'Pago: ${order.paymentMethod}'),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoLine(Icons.notes_outlined, 'Nota: ${order.notes}'),
          ],
          const SizedBox(height: 10),
          const Text(
            'Detalle de Productos:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.pizzaName} (${item.size})',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a cobrar:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const _InfoLine(this.icon, this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: bold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
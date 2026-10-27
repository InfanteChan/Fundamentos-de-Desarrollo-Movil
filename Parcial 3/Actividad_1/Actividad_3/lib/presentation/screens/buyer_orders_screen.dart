import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pizzeria/models/order_model.dart';
import 'package:pizzeria/presentation/providers/order_provider.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class BuyerOrdersScreen extends ConsumerWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Mis Pedidos', showBackButton: false),
      body: ordersAsync.when(
        loading: () => const Center(child: DashedOvenLoader()),
        error: (err, _) => Center(child: Text('Error al cargar pedidos: $err')),
        data: (orders) {
          if (orders.isEmpty) return const _NoOrders();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(buyerOrdersProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _OrderCard(order: orders[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoOrders extends StatelessWidget {
  const _NoOrders();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'Aún no tienes pedidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Explora nuestro menú y ordena tus pizzas favoritas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'pendiente':
        return Colors.orange;
      case 'en_preparacion':
        return Colors.blue;
      case 'en_camino':
        return Colors.purple;
      case 'entregado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  int get _step {
    switch (order.status) {
      case 'pendiente':
        return 1;
      case 'en_preparacion':
        return 2;
      case 'en_camino':
        return 3;
      case 'entregado':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy • hh:mm a').format(order.createdAt);

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName ?? 'Pizzería',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.statusDisplay,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (order.status != 'cancelado') ...[
            Row(
              children: [
                _StepCircle(1, _step, 'Recibido'),
                _StepLine(1, _step),
                _StepCircle(2, _step, 'Cocina'),
                _StepLine(2, _step),
                _StepCircle(3, _step, 'En camino'),
                _StepLine(3, _step),
                _StepCircle(4, _step, 'Entregado'),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const Divider(height: 12),
          const SizedBox(height: 6),
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
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
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

class _StepCircle extends StatelessWidget {
  final int step;
  final int currentStep;
  final String label;

  const _StepCircle(this.step, this.currentStep, this.label);

  @override
  Widget build(BuildContext context) {
    final isDone = currentStep >= step;

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor:
                isDone ? AppColors.primary : AppColors.inputBackground,
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              size: isDone ? 14 : 6,
              color: isDone ? Colors.white : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              color: isDone ? AppColors.primary : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final int step;
  final int currentStep;

  const _StepLine(this.step, this.currentStep);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: currentStep > step ? AppColors.primary : AppColors.inputBackground,
    );
  }
}
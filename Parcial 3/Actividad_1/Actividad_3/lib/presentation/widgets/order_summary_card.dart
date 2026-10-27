import 'package:flutter/material.dart';
import 'package:pizzeria/presentation/widgets/custom_button.dart';
import 'package:pizzeria/theme/app_colors.dart';

class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final VoidCallback? onCheckout;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    this.onCheckout,
  });

  double get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _row('Subtotal', subtotal),
          const SizedBox(height: 10),
          _row('Envío', deliveryFee),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          _row('Total', total, bold: true),
          const SizedBox(height: 20),
          CustomButton(text: 'Pagar', onPressed: onCheckout),
        ],
      ),
    );
  }

  Widget _row(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: bold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
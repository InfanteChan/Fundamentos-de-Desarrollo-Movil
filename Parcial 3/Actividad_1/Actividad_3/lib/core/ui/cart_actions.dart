import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/ui/app_snackbar.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';

Future<void> addToCartWithFeedback(
  BuildContext context,
  WidgetRef ref,
  PizzaModel pizza, {
  int quantity = 1,
  String? size,
}) async {
  final chosenSize =
      size ?? (pizza.sizes.contains('Mediana') ? 'Mediana' : pizza.sizes.first);

  try {
    await ref
        .read(cartProvider.notifier)
        .addItem(pizza, quantity: quantity, size: chosenSize);
    if (!context.mounted) return;
    showAppSnackBar(context, '${pizza.name} ($chosenSize) agregada al carrito');
  } catch (e) {
    debugPrint('Error al agregar al carrito: $e');
    if (!context.mounted) return;
    showAppSnackBar(context, 'No se pudo agregar al carrito');
  }
}
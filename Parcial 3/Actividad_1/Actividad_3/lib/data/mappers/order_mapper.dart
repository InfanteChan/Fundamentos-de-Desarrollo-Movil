import 'package:pizzeria/models/order_model.dart';

class OrderMapper {
  static OrderItemModel itemFromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id']?.toString(),
      orderId: map['order_id']?.toString(),
      pizzaId: map['pizza_id']?.toString(),
      pizzaName: map['pizza_name']?.toString() ?? '',
      quantity: int.tryParse(map['quantity']?.toString() ?? '') ?? 1,
      unitPrice: double.tryParse(map['unit_price']?.toString() ?? '') ?? 0.0,
      size: map['size']?.toString() ?? 'Mediana',
    );
  }

  static Map<String, dynamic> itemToMap(OrderItemModel item, String orderId) {
    final pizzaId = item.pizzaId;
    return {
      'order_id': orderId,
      if (pizzaId != null && pizzaId.isNotEmpty) 'pizza_id': pizzaId,
      'pizza_name': item.pizzaName,
      'quantity': item.quantity,
      'unit_price': item.unitPrice,
      'size': item.size,
    };
  }

  static OrderModel fromMap(Map<String, dynamic> map) {
    final rawItems = map['order_items'];
    final restaurant = map['restaurants'];
    final buyer = map['profiles'];

    return OrderModel(
      id: map['id']?.toString() ?? '',
      buyerId: map['buyer_id']?.toString() ?? '',
      restaurantId: map['restaurant_id']?.toString() ?? '',
      restaurantName: restaurant is Map ? restaurant['name']?.toString() : null,
      buyerName: buyer is Map ? buyer['full_name']?.toString() : null,
      buyerEmail: buyer is Map ? buyer['email']?.toString() : null,
      status: map['status']?.toString() ?? 'pendiente',
      totalAmount: double.tryParse(map['total_amount']?.toString() ?? '') ?? 0.0,
      deliveryAddress: map['delivery_address']?.toString() ?? '',
      paymentMethod: map['payment_method']?.toString() ?? 'Efectivo',
      notes: map['notes']?.toString(),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      items: rawItems is List
          ? rawItems
              .map((i) => itemFromMap(Map<String, dynamic>.from(i as Map)))
              .toList()
          : const [],
    );
  }

  static Map<String, dynamic> toMap(OrderModel order) {
    return {
      'buyer_id': order.buyerId,
      'restaurant_id': order.restaurantId,
      'status': order.status,
      'total_amount': order.totalAmount,
      'delivery_address': order.deliveryAddress,
      'payment_method': order.paymentMethod,
      if (order.notes != null) 'notes': order.notes,
    };
  }
} 
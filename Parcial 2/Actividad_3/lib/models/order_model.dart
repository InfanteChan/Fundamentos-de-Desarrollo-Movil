class OrderItemModel {
  final String? id;
  final String? orderId;
  final String? pizzaId;
  final String pizzaName;
  final int quantity;
  final double unitPrice;
  final String size;

  const OrderItemModel({
    this.id,
    this.orderId,
    this.pizzaId,
    required this.pizzaName,
    required this.quantity,
    required this.unitPrice,
    this.size = 'Mediana',
  });

  double get totalPrice => unitPrice * quantity;
}

class OrderModel {
  final String id;
  final String buyerId;
  final String restaurantId;
  final String? restaurantName;
  final String? buyerName;
  final String? buyerEmail;
  final String status; // pendiente | en_preparacion | en_camino | entregado | cancelado
  final double totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.restaurantId,
    this.restaurantName,
    this.buyerName,
    this.buyerEmail,
    this.status = 'pendiente',
    required this.totalAmount,
    required this.deliveryAddress,
    this.paymentMethod = 'Efectivo',
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  String get statusDisplay {
    switch (status) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_preparacion':
        return 'En Preparación';
      case 'en_camino':
        return 'En Camino';
      case 'entregado':
        return 'Entregado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  OrderModel copyWith({String? status, List<OrderItemModel>? items}) {
    return OrderModel(
      id: id,
      buyerId: buyerId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      buyerName: buyerName,
      buyerEmail: buyerEmail,
      status: status ?? this.status,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: createdAt,
      items: items ?? this.items,
    );
  }
}
import 'package:pizzeria/data/mappers/pizza_mapper.dart';
import 'package:pizzeria/models/pizza_model.dart';

class CartItemModel {
  final String id;
  final PizzaModel pizza;
  final int quantity;
  final String size;

  const CartItemModel({
    required this.id,
    required this.pizza,
    required this.quantity,
    required this.size,
  });

  double get totalPrice => pizza.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      pizza: pizza,
      quantity: quantity ?? this.quantity,
      size: size,
    );
  }

  factory CartItemModel.fromDbMap(Map<String, dynamic> map) {
    final pizzaData = map['pizzas'];

    return CartItemModel(
      id: map['id']?.toString() ?? '',
      pizza: pizzaData is Map
          ? PizzaMapper.fromMap(Map<String, dynamic>.from(pizzaData))
          : PizzaModel(
              id: map['pizza_id']?.toString() ?? '',
              name: 'Pizza no disponible',
              description: '',
              price: 0,
              imageUrl: '',
            ),
      quantity: int.tryParse(map['quantity']?.toString() ?? '') ?? 1,
      size: map['size']?.toString() ?? 'Mediana',
    );
  }
}
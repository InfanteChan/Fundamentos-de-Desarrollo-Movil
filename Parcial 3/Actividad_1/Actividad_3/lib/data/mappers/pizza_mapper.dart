import 'dart:convert';
import 'package:pizzeria/models/pizza_model.dart';

class PizzaMapper {
  static const _defaultSizes = ['Personal', 'Mediana', 'Familiar'];

  static PizzaModel fromMap(Map<String, dynamic> map) {
    final restaurant = map['restaurants'] is Map
        ? Map<String, dynamic>.from(map['restaurants'] as Map)
        : null;

    return PizzaModel(
      id: map['id']?.toString() ?? '',
      restaurantId: map['restaurant_id']?.toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
      imageUrl: map['image_url']?.toString() ?? '',
      sizes: _parseSizes(map['sizes']),
      rating: double.tryParse(map['rating']?.toString() ?? '') ?? 4.8,
      reviewsCount: int.tryParse(map['reviews_count']?.toString() ?? '') ?? 0,
      category: map['category']?.toString() ?? 'Clasicas',
      isAvailable: map['is_available'] != false,
      restaurantName: restaurant?['name']?.toString(),
      restaurantAddress: restaurant?['address']?.toString(),
      restaurantLatitude:
          double.tryParse(restaurant?['latitude']?.toString() ?? ''),
      restaurantLongitude:
          double.tryParse(restaurant?['longitude']?.toString() ?? ''),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }

  static Map<String, dynamic> toMap(PizzaModel pizza) {
    return {
      if (pizza.id.isNotEmpty) 'id': pizza.id,
      if (pizza.restaurantId != null) 'restaurant_id': pizza.restaurantId,
      'name': pizza.name,
      'description': pizza.description,
      'price': pizza.price,
      'image_url': pizza.imageUrl,
      'sizes': pizza.sizes,
      'rating': pizza.rating,
      'reviews_count': pizza.reviewsCount,
      'category': pizza.category,
      'is_available': pizza.isAvailable,
    };
  }

  static List<String> _parseSizes(dynamic raw) {
    dynamic value = raw;
    if (value is String) {
      try {
        value = jsonDecode(value);
      } catch (_) {
        return _defaultSizes;
      }
    }
    if (value is List && value.isNotEmpty) {
      return value.map((e) => e.toString()).toList();
    }
    return _defaultSizes;
  }
}
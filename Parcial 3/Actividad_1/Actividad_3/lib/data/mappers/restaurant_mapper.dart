import 'package:pizzeria/models/restaurant_model.dart';

class RestaurantMapper {
  static RestaurantModel fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id']?.toString() ?? '',
      sellerId: map['seller_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      latitude: double.tryParse(map['latitude']?.toString() ?? '') ?? 19.432608,
      longitude:
          double.tryParse(map['longitude']?.toString() ?? '') ?? -99.133209,
      phone: map['phone']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static Map<String, dynamic> toMap(RestaurantModel restaurant) {
    return {
      if (restaurant.id.isNotEmpty) 'id': restaurant.id,
      'seller_id': restaurant.sellerId,
      'name': restaurant.name,
      'description': restaurant.description,
      'address': restaurant.address,
      'latitude': restaurant.latitude,
      'longitude': restaurant.longitude,
      'phone': restaurant.phone,
      'image_url': restaurant.imageUrl,
    };
  }
}
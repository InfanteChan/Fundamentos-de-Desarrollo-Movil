class RestaurantModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String imageUrl;
  final DateTime createdAt;

  const RestaurantModel({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description = '',
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone = '',
    this.imageUrl = '',
    required this.createdAt,
  });

  RestaurantModel copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
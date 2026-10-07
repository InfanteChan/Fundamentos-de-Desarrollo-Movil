class PizzaModel {
  final String id;
  final String? restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final double rating;
  final int reviewsCount;
  final String category;
  final bool isAvailable;
  final String? restaurantName;
  final String? restaurantAddress;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final DateTime? createdAt;

  const PizzaModel({
    required this.id,
    this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.sizes = const ['Personal', 'Mediana', 'Familiar'],
    this.rating = 4.8,
    this.reviewsCount = 0,
    this.category = 'Clasicas',
    this.isAvailable = true,
    this.restaurantName,
    this.restaurantAddress,
    this.restaurantLatitude,
    this.restaurantLongitude,
    this.createdAt,
  });

  PizzaModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? sizes,
    double? rating,
    int? reviewsCount,
    String? category,
    bool? isAvailable,
    String? restaurantName,
    String? restaurantAddress,
    double? restaurantLatitude,
    double? restaurantLongitude,
    DateTime? createdAt,
  }) {
    return PizzaModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sizes: sizes ?? this.sizes,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurantLatitude: restaurantLatitude ?? this.restaurantLatitude,
      restaurantLongitude: restaurantLongitude ?? this.restaurantLongitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
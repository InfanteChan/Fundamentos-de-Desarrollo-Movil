import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/data/datasources/restaurant_datasource.dart';
import 'package:pizzeria/models/restaurant_model.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';

final restaurantDatasourceProvider = Provider<RestaurantDatasource>((ref) {
  return SupabaseRestaurantDatasource();
});

final restaurantsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  return ref.watch(restaurantDatasourceProvider).getRestaurants();
});

/// La pizzería del vendedor que tiene la sesión iniciada.
class SellerRestaurantNotifier extends AsyncNotifier<RestaurantModel?> {
  RestaurantDatasource get _datasource => ref.read(restaurantDatasourceProvider);

  @override
  Future<RestaurantModel?> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null || !user.isSeller) return null;

    final restaurant = await _datasource.getRestaurantBySellerId(user.id);
    if (restaurant != null) return restaurant;

    // Si todavía no existe, se muestra una pizzería por defecto (id vacío)
    return RestaurantModel(
      id: '',
      sellerId: user.id,
      name: 'Mi Pizzería',
      description: 'Pizzas recién horneadas con los mejores ingredientes.',
      address: 'Dirección por definir',
      latitude: 19.432608,
      longitude: -99.133209,
      createdAt: DateTime.now(),
    );
  }

  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await _datasource.upsertRestaurant(restaurant);
      ref.invalidate(restaurantsProvider);
      return updated;
    });
  }
}

final sellerRestaurantProvider =
    AsyncNotifierProvider<SellerRestaurantNotifier, RestaurantModel?>(
  SellerRestaurantNotifier.new,
);
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/datasources/order_datasource.dart';
import 'package:pizzeria/models/order_model.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';

final orderDatasourceProvider = Provider<OrderDatasource>((ref) {
  return SupabaseOrderDatasource();
});

class BuyerOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  OrderDatasource get _datasource => ref.read(orderDatasourceProvider);

  bool _disposed = false;

  @override
  Future<List<OrderModel>> build() async {
    _disposed = false;
    final userId = ref.watch(authProvider.select((a) => a.value?.id));
    if (userId == null) return [];

    final client = Supabase.instance.client;
    final channel = client
        .channel('public:orders:buyer:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'buyer_id',
            value: userId,
          ),
          callback: (_) => refresh(),
        )
        .subscribe();

    ref.onDispose(() {
      _disposed = true;
      client.removeChannel(channel);
    });

    return _datasource.getOrdersByBuyer(userId);
  }

  Future<void> refresh() async {
    final userId = ref.read(authProvider).value?.id;
    final result = await AsyncValue.guard(() async {
      if (userId == null) return <OrderModel>[];
      return _datasource.getOrdersByBuyer(userId);
    });
    if (!_disposed) state = result;
  }

  Future<OrderModel> placeOrder(OrderModel order) async {
    final created = await _datasource.createOrder(order);
    await refresh();
    return created;
  }
}

final buyerOrdersProvider =
    AsyncNotifierProvider<BuyerOrdersNotifier, List<OrderModel>>(
  BuyerOrdersNotifier.new,
);

/// Pedidos que recibe la pizzería del vendedor, en tiempo real.
class SellerOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  OrderDatasource get _datasource => ref.read(orderDatasourceProvider);

  bool _disposed = false;

  @override
  Future<List<OrderModel>> build() async {
    _disposed = false;
    final restaurant = await ref.watch(sellerRestaurantProvider.future);
    if (restaurant == null || restaurant.id.isEmpty) return [];

    final client = Supabase.instance.client;
    final channel = client
        .channel('public:orders:restaurant:${restaurant.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'restaurant_id',
            value: restaurant.id,
          ),
          callback: (_) => refresh(),
        )
        .subscribe();

    ref.onDispose(() {
      _disposed = true;
      client.removeChannel(channel);
    });

    return _datasource.getOrdersByRestaurant(restaurant.id);
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() async {
      final restaurant = await ref.read(sellerRestaurantProvider.future);
      if (restaurant == null || restaurant.id.isEmpty) return <OrderModel>[];
      return _datasource.getOrdersByRestaurant(restaurant.id);
    });
    if (!_disposed) state = result;
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    await _datasource.updateOrderStatus(orderId, newStatus);
    await refresh();
  }
}

final sellerOrdersProvider =
    AsyncNotifierProvider<SellerOrdersNotifier, List<OrderModel>>(
  SellerOrdersNotifier.new,
);
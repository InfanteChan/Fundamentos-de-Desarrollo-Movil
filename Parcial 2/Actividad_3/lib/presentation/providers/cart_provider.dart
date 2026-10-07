import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/datasources/cart_datasource.dart';
import 'package:pizzeria/models/cart_item_model.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';

/// Costo de envío fijo (como en el original). Cámbialo aquí si quieres.
const double kDeliveryFee = 45.0;

final cartDatasourceProvider = Provider<CartDatasource>((ref) {
  return SupabaseCartDatasource();
});

class CartNotifier extends Notifier<List<CartItemModel>> {
  CartDatasource get _datasource => ref.read(cartDatasourceProvider);

  String? _userId;
  int _generation = 0;

  @override
  List<CartItemModel> build() {
    // Si cambia el usuario (login/logout), este método se vuelve a ejecutar
    final userId = ref.watch(authProvider.select((a) => a.value?.id));
    final generation = ++_generation;
    _userId = userId;

    if (userId == null) return [];

    final client = Supabase.instance.client;
    final channel = client
        .channel('public:cart_items:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'cart_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _load(generation),
        )
        .subscribe();

    ref.onDispose(() {
      _generation++;
      client.removeChannel(channel);
    });

    Future.microtask(() => _load(generation));
    return [];
  }

  Future<void> _load(int generation) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      final items = await _datasource.getCartItems(userId);
      if (generation == _generation) state = items;
    } catch (e) {
      debugPrint('Error al cargar el carrito: $e');
    }
  }

  String _requireUser() {
    final id = _userId;
    if (id == null) throw Exception('Inicia sesión para usar el carrito');
    return id;
  }

  Future<void> addItem(
    PizzaModel pizza, {
    int quantity = 1,
    String size = 'Mediana',
  }) async {
    final userId = _requireUser();
    final existing = state.where((i) => i.pizza.id == pizza.id && i.size == size);
    final newQuantity = (existing.isEmpty ? 0 : existing.first.quantity) + quantity;

    await _datasource.setItem(
      userId: userId,
      pizzaId: pizza.id,
      size: size,
      quantity: newQuantity,
    );
    await _load(_generation);
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) return removeItem(itemId);

    final previous = state;
    state = [
      for (final i in state)
        i.id == itemId ? i.copyWith(quantity: quantity) : i,
    ];
    try {
      await _datasource.updateQuantity(itemId: itemId, quantity: quantity);
    } catch (e) {
      state = previous;
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    final previous = state;
    state = [for (final i in state) if (i.id != itemId) i];
    try {
      await _datasource.removeItem(itemId);
    } catch (e) {
      state = previous;
      rethrow;
    }
  }

  Future<void> clearCart() async {
    final userId = _userId;
    if (userId == null) return;
    await _datasource.clear(userId);
    state = [];
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItemModel>>(CartNotifier.new);

// Valores calculados a partir del carrito
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, i) => sum + i.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, i) => sum + i.totalPrice);
});

final cartDeliveryFeeProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).isEmpty ? 0.0 : kDeliveryFee;
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartSubtotalProvider) + ref.watch(cartDeliveryFeeProvider);
});
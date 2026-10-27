import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/models/cart_item_model.dart';

abstract class CartDatasource {
  Future<List<CartItemModel>> getCartItems(String userId);
  Future<void> setItem({
    required String userId,
    required String pizzaId,
    required String size,
    required int quantity,
  });
  Future<void> updateQuantity({required String itemId, required int quantity});
  Future<void> removeItem(String itemId);
  Future<void> clear(String userId);
}

class SupabaseCartDatasource implements CartDatasource {
  final SupabaseClient _client;

  SupabaseCartDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    final data = await _client
        .from('cart_items')
        .select('*, pizzas(*, restaurants(name, address, latitude, longitude))')
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return data.map<CartItemModel>(CartItemModel.fromDbMap).toList();
  }

  /// Crea la línea del carrito o, si ya existe (misma pizza y tamaño),
  /// reemplaza su cantidad.
  @override
  Future<void> setItem({
    required String userId,
    required String pizzaId,
    required String size,
    required int quantity,
  }) async {
    await _client.from('cart_items').upsert(
      {
        'user_id': userId,
        'pizza_id': pizzaId,
        'size': size,
        'quantity': quantity,
      },
      onConflict: 'user_id,pizza_id,size',
    );
  }

  @override
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', itemId);
  }

  @override
  Future<void> removeItem(String itemId) async {
    await _client.from('cart_items').delete().eq('id', itemId);
  }

  @override
  Future<void> clear(String userId) async {
    await _client.from('cart_items').delete().eq('user_id', userId);
  }
}
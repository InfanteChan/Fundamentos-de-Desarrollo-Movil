import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/mappers/pizza_mapper.dart';
import 'package:pizzeria/models/pizza_model.dart';

abstract class PizzaDatasource {
  Future<List<PizzaModel>> getPizzas();
  Future<List<PizzaModel>> getPizzasByRestaurant(String restaurantId);
  Future<PizzaModel> createPizza(PizzaModel pizza);
  Future<PizzaModel> updatePizza(PizzaModel pizza);
  Future<void> deletePizza(String pizzaId);
}

class SupabasePizzaDatasource implements PizzaDatasource {
  static const _select =
      '*, restaurants(name, address, latitude, longitude)';

  final SupabaseClient _client;

  SupabasePizzaDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<PizzaModel>> getPizzas() async {
    final data = await _client
        .from('pizzas')
        .select(_select)
        .order('created_at', ascending: false);
    return data.map<PizzaModel>(PizzaMapper.fromMap).toList();
  }

  @override
  Future<List<PizzaModel>> getPizzasByRestaurant(String restaurantId) async {
    final data = await _client
        .from('pizzas')
        .select(_select)
        .eq('restaurant_id', restaurantId)
        .order('created_at', ascending: false);
    return data.map<PizzaModel>(PizzaMapper.fromMap).toList();
  }

  @override
  Future<PizzaModel> createPizza(PizzaModel pizza) async {
    final data = await _client
        .from('pizzas')
        .insert(PizzaMapper.toMap(pizza))
        .select(_select)
        .single();
    return PizzaMapper.fromMap(data);
  }

  @override
  Future<PizzaModel> updatePizza(PizzaModel pizza) async {
    final data = await _client
        .from('pizzas')
        .update(PizzaMapper.toMap(pizza))
        .eq('id', pizza.id)
        .select(_select)
        .single();
    return PizzaMapper.fromMap(data);
  }

  @override
  Future<void> deletePizza(String pizzaId) async {
    await _client.from('pizzas').delete().eq('id', pizzaId);
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/mappers/restaurant_mapper.dart';
import 'package:pizzeria/models/restaurant_model.dart';

abstract class RestaurantDatasource {
  Future<List<RestaurantModel>> getRestaurants();
  Future<RestaurantModel?> getRestaurantBySellerId(String sellerId);
  Future<RestaurantModel> upsertRestaurant(RestaurantModel restaurant);
}

class SupabaseRestaurantDatasource implements RestaurantDatasource {
  final SupabaseClient _client;

  SupabaseRestaurantDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    final data = await _client
        .from('restaurants')
        .select()
        .order('created_at', ascending: false);

    return data.map<RestaurantModel>(RestaurantMapper.fromMap).toList();
  }

  @override
  Future<RestaurantModel?> getRestaurantBySellerId(String sellerId) async {
    final data = await _client
        .from('restaurants')
        .select()
        .eq('seller_id', sellerId)
        .maybeSingle();

    return data == null ? null : RestaurantMapper.fromMap(data);
  }

  @override
  Future<RestaurantModel> upsertRestaurant(RestaurantModel restaurant) async {
    final response = await _client
        .from('restaurants')
        .upsert(RestaurantMapper.toMap(restaurant))
        .select()
        .single();

    return RestaurantMapper.fromMap(response);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/datasources/pizza_datasource.dart';
import 'package:pizzeria/models/pizza_model.dart';

final pizzaDatasourceProvider = Provider<PizzaDatasource>((ref) {
  return SupabasePizzaDatasource();
});

/// Todas las pizzas del menú, con actualización en tiempo real.
final pizzasProvider = FutureProvider<List<PizzaModel>>((ref) async {
  final client = Supabase.instance.client;

  final channel = client
      .channel('public:pizzas:all')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'pizzas',
        callback: (_) => ref.invalidateSelf(),
      )
      .subscribe();

  ref.onDispose(() => client.removeChannel(channel));

  return ref.read(pizzaDatasourceProvider).getPizzas();
});
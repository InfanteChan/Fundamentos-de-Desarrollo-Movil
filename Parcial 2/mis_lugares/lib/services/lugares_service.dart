import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lugar.dart';

class LugaresService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<Lugar>> listar() async {
    final data = await _db
        .from('lugares')
        .select()
        .order('created_at', ascending: false);
    return data.map<Lugar>((m) => Lugar.fromMap(m)).toList();
  }

  Future<void> crear(Lugar lugar) async {
    await _db.from('lugares').insert(lugar.toMap());
  }

  Future<void> editar(Lugar lugar) async {
    await _db.from('lugares').update(lugar.toMap()).eq('id', lugar.id!);
  }

  Future<void> eliminar(String id) async {
    await _db.from('lugares').delete().eq('id', id);
  }
}
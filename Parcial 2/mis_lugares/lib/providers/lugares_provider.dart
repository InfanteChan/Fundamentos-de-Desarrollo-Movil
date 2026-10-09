import 'package:flutter/foundation.dart';
import '../models/lugar.dart';
import '../services/lugares_service.dart';

class LugaresProvider extends ChangeNotifier {
  final LugaresService _service = LugaresService();

  List<Lugar> _lugares = [];
  bool _cargando = false;
  String? _error;

  List<Lugar> get lugares => _lugares;
  bool get cargando => _cargando;
  String? get error => _error;

  /// [limpiar] vacía la lista antes de cargar (útil al cambiar de usuario).
  Future<void> cargar({bool limpiar = true}) async {
    if (limpiar) _lugares = [];
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _lugares = await _service.listar();
    } catch (_) {
      _error = 'No se pudieron cargar tus lugares. Revisa tu internet.';
    }
    _cargando = false;
    notifyListeners();
  }

  // Estos métodos dejan pasar el error para que la pantalla lo muestre.
  Future<void> crear(Lugar lugar) async {
    await _service.crear(lugar);
    await cargar(limpiar: false);
  }

  Future<void> editar(Lugar lugar) async {
    await _service.editar(lugar);
    await cargar(limpiar: false);
  }

  Future<void> eliminar(String id) async {
    await _service.eliminar(id);
    await cargar(limpiar: false);
  }
}
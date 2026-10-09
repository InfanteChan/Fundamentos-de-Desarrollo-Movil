import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/lugar.dart';
import '../services/lugares_service.dart';
import '../services/storage_service.dart';

class LugaresProvider extends ChangeNotifier {
  final LugaresService _service = LugaresService();
  final StorageService _storage = StorageService();

  List<Lugar> _lugares = [];
  bool _cargando = false;
  String? _error;
  String _busqueda = '';
  String? _categoriaFiltro;

  List<Lugar> get lugares => _lugares;
  bool get cargando => _cargando;
  String? get error => _error;
  String? get categoriaFiltro => _categoriaFiltro;

  /// Lugares que cumplen la búsqueda por nombre y el filtro de categoría.
  List<Lugar> get lugaresFiltrados {
    final q = _busqueda.toLowerCase();
    return _lugares.where((l) {
      final coincideNombre = q.isEmpty || l.nombre.toLowerCase().contains(q);
      final coincideCategoria =
          _categoriaFiltro == null || l.categoria == _categoriaFiltro;
      return coincideNombre && coincideCategoria;
    }).toList();
  }

  void setBusqueda(String texto) {
    _busqueda = texto.trim();
    notifyListeners();
  }

  void setCategoria(String? categoria) {
    _categoriaFiltro = categoria;
    notifyListeners();
  }

  /// [limpiar] vacía la lista y los filtros (útil al cambiar de usuario).
  Future<void> cargar({bool limpiar = true}) async {
    if (limpiar) {
      _lugares = [];
      _busqueda = '';
      _categoriaFiltro = null;
    }
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
  Future<void> crear(Lugar lugar, {XFile? foto}) async {
    var nuevo = lugar;
    if (foto != null) {
      nuevo = lugar.copyWith(fotoUrl: await _storage.subirFoto(foto));
    }
    await _service.crear(nuevo);
    await cargar(limpiar: false);
  }

  Future<void> editar(Lugar lugar, {XFile? fotoNueva}) async {
    var actualizado = lugar;
    String? fotoAnterior;
    if (fotoNueva != null) {
      fotoAnterior = lugar.fotoUrl;
      actualizado = lugar.copyWith(fotoUrl: await _storage.subirFoto(fotoNueva));
    }
    await _service.editar(actualizado);
    await _borrarFotoSilencioso(fotoAnterior);
    await cargar(limpiar: false);
  }

  Future<void> eliminar(Lugar lugar) async {
    await _service.eliminar(lugar.id!);
    await _borrarFotoSilencioso(lugar.fotoUrl);
    await cargar(limpiar: false);
  }

  /// Si falla el borrado de la foto vieja, no debe romper la operación.
  Future<void> _borrarFotoSilencioso(String? url) async {
    if (url == null) return;
    try {
      await _storage.eliminarFoto(url);
    } catch (_) {}
  }
}
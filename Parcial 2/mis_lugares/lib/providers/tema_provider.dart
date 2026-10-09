import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemaProvider extends ChangeNotifier {
  static const _clave = 'modo_oscuro';
  ThemeMode _modo = ThemeMode.system;

  ThemeMode get modo => _modo;

  /// Lee la preferencia guardada; si no hay ninguna, sigue al sistema.
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getBool(_clave);
    if (guardado != null) {
      _modo = guardado ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> alternar(bool oscuro) async {
    _modo = oscuro ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clave, oscuro);
  }
}
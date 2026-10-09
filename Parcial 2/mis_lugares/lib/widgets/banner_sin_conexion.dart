import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lugares_provider.dart';

class BannerSinConexion extends StatefulWidget {
  final Widget child;
  const BannerSinConexion({super.key, required this.child});

  @override
  State<BannerSinConexion> createState() => _BannerSinConexionState();
}

class _BannerSinConexionState extends State<BannerSinConexion> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _sinConexion = false;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then(_actualizar);
    _sub = Connectivity().onConnectivityChanged.listen(_actualizar);
  }

  void _actualizar(List<ConnectivityResult> resultados) {
    if (!mounted) return;
    final sin = resultados.every((r) => r == ConnectivityResult.none);
    if (sin == _sinConexion) return;

    // Al recuperar la conexión, vuelve a cargar los lugares.
    if (!sin && _sinConexion) {
      context.read<LugaresProvider>().cargar(limpiar: false);
    }
    setState(() => _sinConexion = sin);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _sinConexion
              ? Container(
                  width: double.infinity,
                  color: colores.errorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 18, color: colores.onErrorContainer),
                      const SizedBox(width: 8),
                      Text(
                        'Sin conexión a internet',
                        style: TextStyle(color: colores.onErrorContainer),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
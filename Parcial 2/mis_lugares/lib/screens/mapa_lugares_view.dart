import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../core/categorias.dart';
import '../models/lugar.dart';
import '../providers/lugares_provider.dart';
import '../services/ubicacion_service.dart';
import 'lugar_form_screen.dart';

class MapaLugaresView extends StatefulWidget {
  const MapaLugaresView({super.key});

  @override
  State<MapaLugaresView> createState() => _MapaLugaresViewState();
}

class _MapaLugaresViewState extends State<MapaLugaresView> {
  static const _centroDefecto = LatLng(19.4326, -99.1332);

  final _controller = MapController();
  final _ubicacionService = UbicacionService();
  LatLng? _miUbicacion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sinLugares = context.read<LugaresProvider>().lugares.isEmpty;
      _ubicarme(irAlPunto: sinLugares);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ubicarme({required bool irAlPunto}) async {
    try {
      final punto = await _ubicacionService.obtenerActual();
      if (!mounted) return;
      setState(() => _miUbicacion = punto);
      if (irAlPunto) _controller.move(punto, 16);
    } on UbicacionException catch (e) {
      _mensaje(e.mensaje);
    } catch (_) {
      _mensaje('No se pudo obtener tu ubicación.');
    }
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _verTodos(List<Lugar> lugares) {
    if (lugares.isEmpty) return;
    _controller.fitCamera(
      CameraFit.coordinates(
        coordinates: lugares.map((l) => LatLng(l.latitud, l.longitud)).toList(),
        padding: const EdgeInsets.all(64),
        maxZoom: 16,
      ),
    );
  }

  void _verDetalle(Lugar lugar) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              if (lugar.fotoUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  lugar.fotoUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(iconoDeCategoria(lugar.categoria)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(lugar.nombre,
                      style: Theme.of(ctx).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(lugar.categoria),
            if (lugar.descripcion?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(lugar.descripcion!),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LugarFormScreen(lugar: lugar)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lugares = context.watch<LugaresProvider>().lugares;
    final puntos = lugares.map((l) => LatLng(l.latitud, l.longitud)).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: _centroDefecto,
            initialZoom: 12,
            initialCameraFit: puntos.isEmpty
                ? null
                : CameraFit.coordinates(
                    coordinates: puntos,
                    padding: const EdgeInsets.all(64),
                    maxZoom: 16,
                  ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mis_lugares',
            ),
            MarkerLayer(
              markers: [
                if (_miUbicacion != null)
                  Marker(
                    point: _miUbicacion!,
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                for (final lugar in lugares)
                  Marker(
                    point: LatLng(lugar.latitud, lugar.longitud),
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => _verDetalle(lugar),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(iconoDeCategoria(lugar.categoria),
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text('© OpenStreetMap contributors'),
            ),
          ],
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Ver todos mis lugares',
                onPressed: () => _verTodos(lugares),
                child: const Icon(Icons.zoom_out_map),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Mi ubicación',
                onPressed: () => _ubicarme(irAlPunto: true),
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/ubicacion_service.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? inicial; // null = lugar nuevo
  const MapPickerScreen({super.key, this.inicial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _centroDefecto = LatLng(19.4326, -99.1332);

  final _controller = MapController();
  final _ubicacionService = UbicacionService();
  LatLng? _seleccion;
  LatLng? _miUbicacion;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _seleccion = widget.inicial;
    // Si es un lugar nuevo, arranca en mi ubicación.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _usarMiUbicacion(seleccionar: widget.inicial == null),
    );
  }

  Future<void> _usarMiUbicacion({required bool seleccionar}) async {
    setState(() => _buscando = true);
    try {
      final punto = await _ubicacionService.obtenerActual();
      if (!mounted) return;
      setState(() {
        _miUbicacion = punto;
        if (seleccionar) _seleccion = punto;
      });
      if (seleccionar) _controller.move(punto, 16);
    } on UbicacionException catch (e) {
      _mensaje(e.mensaje);
    } catch (_) {
      _mensaje('No se pudo obtener tu ubicación.');
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elige la ubicación')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: widget.inicial ?? _centroDefecto,
              initialZoom: widget.inicial != null ? 16 : 13,
              onTap: (_, punto) => setState(() => _seleccion = punto),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.android.application',
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
                  if (_seleccion != null)
                    Marker(
                      point: _seleccion!,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 48),
                    ),
                ],
              ),
              const SimpleAttributionWidget(
                source: Text('© OpenStreetMap contributors'),
              ),
            ],
          ),
          const Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text('Toca el mapa para elegir el punto',
                    textAlign: TextAlign.center),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 88,
            child: FloatingActionButton.small(
              heroTag: null,
              onPressed:
                  _buscando ? null : () => _usarMiUbicacion(seleccionar: true),
              child: _buscando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: FilledButton.icon(
              onPressed: _seleccion == null
                  ? null
                  : () => Navigator.pop(context, _seleccion),
              icon: const Icon(Icons.check),
              label: const Text('Confirmar ubicación'),
            ),
          ),
        ],
      ),
    );
  }
}
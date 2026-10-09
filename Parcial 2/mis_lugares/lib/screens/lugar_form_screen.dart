import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../core/categorias.dart';
import '../models/lugar.dart';
import '../providers/lugares_provider.dart';
import 'map_picker_screen.dart';

class LugarFormScreen extends StatefulWidget {
  final Lugar? lugar; // null = agregar, con valor = editar
  const LugarFormScreen({super.key, this.lugar});

  @override
  State<LugarFormScreen> createState() => _LugarFormScreenState();
}

class _LugarFormScreenState extends State<LugarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descCtrl;
  late String _categoria;
  LatLng? _punto;
  XFile? _foto; // foto nueva elegida
  Uint8List? _fotoBytes; // para la vista previa
  bool _guardando = false;

  bool get _esEdicion => widget.lugar != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lugar;
    _nombreCtrl = TextEditingController(text: l?.nombre ?? '');
    _descCtrl = TextEditingController(text: l?.descripcion ?? '');
    _categoria = l?.categoria ?? categorias.keys.first;
    if (l != null) _punto = LatLng(l.latitud, l.longitud);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _elegirFoto(ImageSource fuente) async {
    try {
      final foto = await _picker.pickImage(
        source: fuente,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (foto == null) return;
      final bytes = await foto.readAsBytes();
      if (!mounted) return;
      setState(() {
        _foto = foto;
        _fotoBytes = bytes;
      });
    } catch (_) {
      _mensaje('No se pudo abrir la cámara o la galería.');
    }
  }

  Future<void> _elegirUbicacion() async {
    final punto = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => MapPickerScreen(inicial: _punto)),
    );
    if (punto != null) setState(() => _punto = punto);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    /*if (!_esEdicion && _foto == null) {
      _mensaje('Agrega una foto del lugar.');
      return;
    }*/
    if (_punto == null) {
      _mensaje('Elige la ubicación en el mapa.');
      return;
    }
    setState(() => _guardando = true);

    final lugar = Lugar(
      id: widget.lugar?.id,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      categoria: _categoria,
      latitud: _punto!.latitude,
      longitud: _punto!.longitude,
      fotoUrl: widget.lugar?.fotoUrl,
    );

    try {
      final provider = context.read<LugaresProvider>();
      if (_esEdicion) {
        await provider.editar(lugar, fotoNueva: _foto);
      } else {
        await provider.crear(lugar, foto: _foto);
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      _mensaje('No se pudo guardar. Revisa tu internet.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _vistaFoto() {
    const placeholder = Center(
      child: Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
    );
    Widget contenido = placeholder;
    if (_fotoBytes != null) {
      contenido = Image.memory(_fotoBytes!, fit: BoxFit.cover);
    } else if (widget.lugar?.fotoUrl != null) {
      contenido = Image.network(
        widget.lugar!.fotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 180,
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: contenido,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar lugar' : 'Nuevo lugar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _vistaFoto(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _elegirFoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                    ),
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _elegirFoto(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Cámara'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Escribe un nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: categorias.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Row(children: [
                            Icon(e.value, size: 20),
                            const SizedBox(width: 8),
                            Text(e.key),
                          ]),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _elegirUbicacion,
                  icon: const Icon(Icons.map),
                  label: Text(
                    _punto == null
                        ? 'Elegir ubicación en el mapa'
                        : '${_punto!.latitude.toStringAsFixed(5)}, '
                            '${_punto!.longitude.toStringAsFixed(5)}  (cambiar)',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_esEdicion ? 'Guardar cambios' : 'Guardar lugar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
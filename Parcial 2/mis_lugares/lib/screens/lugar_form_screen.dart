import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/categorias.dart';
import '../models/lugar.dart';
import '../providers/lugares_provider.dart';

class LugarFormScreen extends StatefulWidget {
  final Lugar? lugar; // null = agregar, con valor = editar
  const LugarFormScreen({super.key, this.lugar});

  @override
  State<LugarFormScreen> createState() => _LugarFormScreenState();
}

class _LugarFormScreenState extends State<LugarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late String _categoria;
  bool _guardando = false;

  bool get _esEdicion => widget.lugar != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lugar;
    _nombreCtrl = TextEditingController(text: l?.nombre ?? '');
    _descCtrl = TextEditingController(text: l?.descripcion ?? '');
    _latCtrl = TextEditingController(text: l?.latitud.toString() ?? '');
    _lngCtrl = TextEditingController(text: l?.longitud.toString() ?? '');
    _categoria = l?.categoria ?? categorias.keys.first;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  double? _numero(String texto) => double.tryParse(texto.trim().replaceAll(',', '.'));

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final lugar = Lugar(
      id: widget.lugar?.id,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      categoria: _categoria,
      latitud: _numero(_latCtrl.text)!,
      longitud: _numero(_lngCtrl.text)!,
      fotoUrl: widget.lugar?.fotoUrl,
    );

    try {
      final provider = context.read<LugaresProvider>();
      if (_esEdicion) {
        await provider.editar(lugar);
      } else {
        await provider.crear(lugar);
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar. Revisa tu internet.')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
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
              // TEMPORAL: en el Paso 5 esto se reemplaza por el mapa.
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitud',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = _numero(v ?? '');
                        return (n == null || n < -90 || n > 90) ? 'Inválida' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitud',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = _numero(v ?? '');
                        return (n == null || n < -180 || n > 180) ? 'Inválida' : null;
                      },
                    ),
                  ),
                ],
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
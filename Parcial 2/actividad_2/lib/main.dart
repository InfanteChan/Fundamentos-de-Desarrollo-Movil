import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://azwrppvorisinzlqrryz.supabase.co',
    publishableKey: 'sb_publishable_lPgp_0MgS5JDo-g3k7G2cg_2EtAS6pp',
  );

  runApp(const MiApp());
}

final supabase = Supabase.instance.client;

// ---------- Modelo ----------
class Cancion {
  final int id;
  final String titulo;
  final String artista;
  final String? album;
  final int? anio;
  final int? duracionSeg;
  final bool favorita;

  Cancion({
    required this.id,
    required this.titulo,
    required this.artista,
    this.album,
    this.anio,
    this.duracionSeg,
    required this.favorita,
  });

  factory Cancion.fromMap(Map<String, dynamic> m) => Cancion(
        id: m['id'] as int,
        titulo: m['titulo'] as String,
        artista: m['artista'] as String,
        album: m['album'] as String?,
        anio: m['anio'] as int?,
        duracionSeg: m['duracion_seg'] as int?,
        favorita: m['favorita'] as bool,
      );

  Cancion copyWith({bool? favorita}) => Cancion(
        id: id,
        titulo: titulo,
        artista: artista,
        album: album,
        anio: anio,
        duracionSeg: duracionSeg,
        favorita: favorita ?? this.favorita,
      );

  String get duracion {
    if (duracionSeg == null) return '--:--';
    final m = duracionSeg! ~/ 60;
    final s = (duracionSeg! % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ---------- Orden ----------
enum Orden { titulo, artista, anio, duracion }

extension OrdenX on Orden {
  String get etiqueta => switch (this) {
        Orden.titulo => 'Título',
        Orden.artista => 'Artista',
        Orden.anio => 'Año',
        Orden.duracion => 'Duración',
      };
}

// ---------- App ----------
class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Música',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const PantallaCanciones(),
    );
  }
}

class PantallaCanciones extends StatefulWidget {
  const PantallaCanciones({super.key});

  @override
  State<PantallaCanciones> createState() => _PantallaCancionesState();
}

class _PantallaCancionesState extends State<PantallaCanciones> {
  List<Cancion> _canciones = [];
  bool _cargando = true;
  String? _error;
  String _busqueda = '';
  bool _soloFavoritas = false;
  Orden _orden = Orden.titulo;
  bool _ascendente = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  // ---------- Leer ----------
  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await supabase.from('canciones').select();
      setState(() {
        _canciones = (data as List)
            .map((e) => Cancion.fromMap(e as Map<String, dynamic>))
            .toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  // ---------- Favorita ----------
  Future<void> _toggleFavorita(Cancion c) async {
    final nuevo = !c.favorita;
    final idx = _canciones.indexWhere((x) => x.id == c.id);
    setState(() => _canciones[idx] = c.copyWith(favorita: nuevo));

    try {
      final res = await supabase
          .from('canciones')
          .update({'favorita': nuevo})
          .eq('id', c.id)
          .select();
      if (res.isEmpty) throw 'Sin permiso para actualizar (revisa la política RLS)';
    } catch (e) {
      setState(() => _canciones[idx] = c);
      _mensaje('No se pudo actualizar: $e');
    }
  }

  // ---------- Agregar ----------
  Future<void> _agregar() async {
    final nueva = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const FormularioCancion(),
    );
    if (nueva == null) return;

    try {
      final fila =
          await supabase.from('canciones').insert(nueva).select().single();
      setState(() => _canciones.add(Cancion.fromMap(fila)));
      _mensaje('Canción agregada');
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        _mensaje('Esa canción ya existe');
      } else {
        _mensaje('No se pudo agregar: ${e.message}');
      }
    } catch (e) {
      _mensaje('No se pudo agregar: $e');
    }
  }

  // ---------- Eliminar ----------
  Future<bool> _confirmarYEliminar(Cancion c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text('¿Eliminar "${c.titulo}" de ${c.artista}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return false;

    try {
      final res =
          await supabase.from('canciones').delete().eq('id', c.id).select();
      if (res.isEmpty) throw 'Sin permiso para eliminar (revisa la política RLS)';
      _mensaje('"${c.titulo}" eliminada');
      return true;
    } catch (e) {
      _mensaje('No se pudo eliminar: $e');
      return false;
    }
  }

  // ---------- Filtrar y ordenar ----------
  int _comparar(Cancion a, Cancion b) {
    int r = switch (_orden) {
      Orden.titulo => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()),
      Orden.artista =>
        a.artista.toLowerCase().compareTo(b.artista.toLowerCase()),
      Orden.anio => (a.anio ?? 0).compareTo(b.anio ?? 0),
      Orden.duracion => (a.duracionSeg ?? 0).compareTo(b.duracionSeg ?? 0),
    };
    if (r == 0) r = a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
    return _ascendente ? r : -r;
  }

  List<Cancion> get _filtradas {
    final q = _busqueda.toLowerCase();
    final lista = _canciones.where((c) {
      final coincide = c.titulo.toLowerCase().contains(q) ||
          c.artista.toLowerCase().contains(q) ||
          (c.album ?? '').toLowerCase().contains(q);
      return coincide && (!_soloFavoritas || c.favorita);
    }).toList();
    lista.sort(_comparar);
    return lista;
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = _filtradas.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Música',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<Orden>(
            tooltip: 'Ordenar por',
            icon: const Icon(Icons.sort),
            onSelected: (o) => setState(() {
              if (o == _orden) {
                _ascendente = !_ascendente;
              } else {
                _orden = o;
                _ascendente = true;
              }
            }),
            itemBuilder: (_) => [
              for (final o in Orden.values)
                PopupMenuItem(
                  value: o,
                  child: Row(
                    children: [
                      Expanded(child: Text(o.etiqueta)),
                      if (o == _orden)
                        Icon(
                          _ascendente
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 18,
                        ),
                    ],
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Solo favoritas',
            icon: Icon(_soloFavoritas ? Icons.favorite : Icons.favorite_border),
            color: _soloFavoritas ? Colors.redAccent : null,
            onPressed: () => setState(() => _soloFavoritas = !_soloFavoritas),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregar,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              hintText: 'Buscar canción, artista o álbum',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor:
                  WidgetStatePropertyAll(cs.surfaceContainerHighest),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Orden: ${_orden.etiqueta} ${_ascendente ? '↑' : '↓'}  ·  $total canciones',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          Expanded(child: _contenido()),
        ],
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _cargar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final lista = _filtradas;
    if (lista.isEmpty) {
      return const Center(child: Text('No se encontraron canciones'));
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
        itemCount: lista.length,
        itemBuilder: (context, i) {
          final c = lista[i];
          return Dismissible(
            key: ValueKey(c.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmarYEliminar(c),
            onDismissed: (_) =>
                setState(() => _canciones.removeWhere((x) => x.id == c.id)),
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.only(right: 24),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: TarjetaCancion(
              cancion: c,
              onFavorita: () => _toggleFavorita(c),
            ),
          );
        },
      ),
    );
  }
}

// ---------- Formulario para agregar ----------
class FormularioCancion extends StatefulWidget {
  const FormularioCancion({super.key});

  @override
  State<FormularioCancion> createState() => _FormularioCancionState();
}

class _FormularioCancionState extends State<FormularioCancion> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _artista = TextEditingController();
  final _album = TextEditingController();
  final _anio = TextEditingController();
  final _duracion = TextEditingController();
  bool _favorita = false;

  @override
  void dispose() {
    _titulo.dispose();
    _artista.dispose();
    _album.dispose();
    _anio.dispose();
    _duracion.dispose();
    super.dispose();
  }

  // Acepta "3:45" o "225" (segundos)
  int? _parseDuracion(String texto) {
    final t = texto.trim();
    if (t.isEmpty) return null;
    if (t.contains(':')) {
      final partes = t.split(':');
      if (partes.length != 2) return null;
      final m = int.tryParse(partes[0]);
      final s = int.tryParse(partes[1]);
      if (m == null || s == null || s >= 60) return null;
      return m * 60 + s;
    }
    return int.tryParse(t);
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final album = _album.text.trim();
    final anio = _anio.text.trim();
    Navigator.pop(context, {
      'titulo': _titulo.text.trim(),
      'artista': _artista.text.trim(),
      'album': album.isEmpty ? null : album,
      'anio': anio.isEmpty ? null : int.parse(anio),
      'duracion_seg': _parseDuracion(_duracion.text),
      'favorita': _favorita,
    });
  }

  InputDecoration _deco(String etiqueta, IconData icono) => InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nueva canción',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titulo,
                decoration: _deco('Título *', Icons.music_note),
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _artista,
                decoration: _deco('Artista *', Icons.person),
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _album,
                decoration: _deco('Álbum', Icons.album),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _anio,
                      decoration: _deco('Año', Icons.calendar_today),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = int.tryParse(v);
                        if (n == null || n < 1900 || n > 2100) {
                          return '1900 - 2100';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _duracion,
                      decoration: _deco('Duración', Icons.timer_outlined)
                          .copyWith(hintText: '3:45'),
                      keyboardType: TextInputType.datetime,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final s = _parseDuracion(v);
                        if (s == null || s <= 0) return 'Ej. 3:45';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Marcar como favorita'),
                value: _favorita,
                onChanged: (v) => setState(() => _favorita = v),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Tarjeta ----------
class TarjetaCancion extends StatelessWidget {
  final Cancion cancion;
  final VoidCallback onFavorita;

  const TarjetaCancion({
    super.key,
    required this.cancion,
    required this.onFavorita,
  });

  Color _colorArtista(String artista) {
    final hue = (artista.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = _colorArtista(cancion.artista);

    return Card(
      elevation: 0,
      color: tema.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cancion.titulo.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cancion.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cancion.artista,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodyMedium
                        ?.copyWith(color: tema.colorScheme.primary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (cancion.album != null)
                        _Chip(icono: Icons.album, texto: cancion.album!),
                      if (cancion.anio != null)
                        _Chip(
                            icono: Icons.calendar_today,
                            texto: '${cancion.anio}'),
                      _Chip(
                          icono: Icons.timer_outlined, texto: cancion.duracion),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavorita,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  cancion.favorita ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(cancion.favorita),
                  color: cancion.favorita ? Colors.redAccent : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Chip({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
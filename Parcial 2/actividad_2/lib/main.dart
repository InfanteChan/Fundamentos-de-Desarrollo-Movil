import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://TU-PROYECTO.supabase.co',
    anonKey: 'TU_ANON_KEY',
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

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await supabase
          .from('canciones')
          .select()
          .order('titulo', ascending: true);
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

  Future<void> _toggleFavorita(Cancion c) async {
    final nuevo = !c.favorita;
    final idx = _canciones.indexWhere((x) => x.id == c.id);

    // Actualización optimista en la UI
    setState(() => _canciones[idx] = c.copyWith(favorita: nuevo));

    try {
      await supabase.from('canciones').update({'favorita': nuevo}).eq('id', c.id);
    } catch (e) {
      // Si falla, revertimos
      setState(() => _canciones[idx] = c);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar: $e')),
        );
      }
    }
  }

  List<Cancion> get _filtradas {
    final q = _busqueda.toLowerCase();
    return _canciones.where((c) {
      final coincide = c.titulo.toLowerCase().contains(q) ||
          c.artista.toLowerCase().contains(q) ||
          (c.album ?? '').toLowerCase().contains(q);
      return coincide && (!_soloFavoritas || c.favorita);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Música',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Solo favoritas',
            icon: Icon(_soloFavoritas ? Icons.favorite : Icons.favorite_border),
            color: _soloFavoritas ? Colors.redAccent : null,
            onPressed: () => setState(() => _soloFavoritas = !_soloFavoritas),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              hintText: 'Buscar canción, artista o álbum',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor:
                  WidgetStatePropertyAll(cs.surfaceContainerHighest),
              onChanged: (v) => setState(() => _busqueda = v),
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
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        itemCount: lista.length,
        itemBuilder: (_, i) => TarjetaCancion(
          cancion: lista[i],
          onFavorita: () => _toggleFavorita(lista[i]),
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

  // Color estable por artista para que cada uno tenga su "identidad"
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
            // "Portada" generada con degradado + inicial
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.55)],
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
                      _Chip(icono: Icons.timer_outlined, texto: cancion.duracion),
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
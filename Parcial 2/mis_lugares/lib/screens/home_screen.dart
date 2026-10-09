import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/categorias.dart';
import '../models/lugar.dart';
import '../providers/lugares_provider.dart';
import '../services/auth_service.dart';
import 'lugar_form_screen.dart';
import 'mapa_lugares_view.dart';
import 'perfil_view.dart';
  import '../widgets/banner_sin_conexion.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _busquedaCtrl = TextEditingController();
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    // Carga los lugares del usuario al entrar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LugaresProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _abrirFormulario([Lugar? lugar]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LugarFormScreen(lugar: lugar)),
    );
  }

  Future<void> _confirmarEliminar(Lugar lugar) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar lugar'),
        content: Text('¿Seguro que quieres eliminar "${lugar.nombre}"?'),
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
    if (confirmado != true || !mounted) return;

    try {
      await context.read<LugaresProvider>().eliminar(lugar);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar. Revisa tu internet.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LugaresProvider>();

    return Scaffold(
      appBar: AppBar(
                title: Text(
          _indice == 0 && provider.lugares.isNotEmpty
              ? 'Mis Lugares (${provider.lugares.length})'
              : 'Mis Lugares',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _auth.cerrarSesion,
          ),
        ],
      ),
            floatingActionButton: _indice == 2
          ? null
          : FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Agregar'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Lista'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Mapa'),
                    NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
            body: BannerSinConexion(
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (actual, anteriores) => Stack(
                  fit: StackFit.expand,
                  children: [...anteriores, ?actual],
                  ),
        child: KeyedSubtree(
          key: ValueKey(_indice),
          child: switch (_indice) {
            0 => _cuerpo(provider),
            1 => const MapaLugaresView(),
            _ => const PerfilView(),
          },
        ),
      ),
      ),
    );
  }

  Widget _miniatura(Lugar lugar) {
    final icono = CircleAvatar(child: Icon(iconoDeCategoria(lugar.categoria)));
    if (lugar.fotoUrl == null) return icono;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        lugar.fotoUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => icono,
      ),
    );
  }

  Widget _cuerpo(LugaresProvider provider) {
    if (provider.cargando && provider.lugares.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: provider.cargar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (provider.lugares.isEmpty) {
      return const Center(
        child: Text('Aún no tienes lugares.\nToca "Agregar" para guardar el primero.',
            textAlign: TextAlign.center),
      );
    }

    final filtrados = provider.lugaresFiltrados;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _busquedaCtrl,
            onChanged: provider.setBusqueda,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre',
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busquedaCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _busquedaCtrl.clear();
                        provider.setBusqueda('');
                      },
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Todas'),
                  selected: provider.categoriaFiltro == null,
                  onSelected: (_) => provider.setCategoria(null),
                ),
              ),
              for (final e in categorias.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(e.value, size: 18),
                    label: Text(e.key),
                    showCheckmark: false,
                    selected: provider.categoriaFiltro == e.key,
                    onSelected: (_) => provider.setCategoria(
                      provider.categoriaFiltro == e.key ? null : e.key,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: filtrados.isEmpty
              ? const Center(child: Text('Ningún lugar coincide con tu búsqueda.'))
              : RefreshIndicator(
                  onRefresh: () => provider.cargar(limpiar: false),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: filtrados.length,
                    itemBuilder: (context, i) {
                      final lugar = filtrados[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: _miniatura(lugar),
                          title: Text(lugar.nombre),
                          subtitle: Text(
                            lugar.descripcion?.isNotEmpty == true
                                ? '${lugar.categoria} · ${lugar.descripcion}'
                                : lugar.categoria,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _abrirFormulario(lugar),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'editar') _abrirFormulario(lugar);
                              if (v == 'eliminar') _confirmarEliminar(lugar);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'editar', child: Text('Editar')),
                              PopupMenuItem(
                                  value: 'eliminar', child: Text('Eliminar')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
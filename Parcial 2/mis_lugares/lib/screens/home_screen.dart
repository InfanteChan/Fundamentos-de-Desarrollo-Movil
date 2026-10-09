import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/categorias.dart';
import '../models/lugar.dart';
import '../providers/lugares_provider.dart';
import '../services/auth_service.dart';
import 'lugar_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    // Carga los lugares del usuario al entrar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LugaresProvider>().cargar();
    });
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
      await context.read<LugaresProvider>().eliminar(lugar.id!);
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
        title: const Text('Mis Lugares'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _auth.cerrarSesion,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Agregar'),
      ),
      body: _cuerpo(provider),
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

    return RefreshIndicator(
      onRefresh: () => provider.cargar(limpiar: false),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: provider.lugares.length,
        itemBuilder: (context, i) {
          final lugar = provider.lugares[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Icon(iconoDeCategoria(lugar.categoria))),
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
                  PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
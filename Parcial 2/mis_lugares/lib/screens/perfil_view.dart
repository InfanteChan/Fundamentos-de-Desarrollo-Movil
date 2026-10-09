import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/categorias.dart';
import '../providers/lugares_provider.dart';
import '../providers/tema_provider.dart';
import '../services/auth_service.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  Future<void> _confirmarCerrarSesion(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado == true) await AuthService().cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;
    final nombre = (usuario?.userMetadata?['nombre'] as String?) ?? 'Usuario';
    final email = usuario?.email ?? '';
    final lugares = context.watch<LugaresProvider>().lugares;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colores = Theme.of(context).colorScheme;

    // Cuántos lugares hay por categoría.
    final porCategoria = <String, int>{};
    for (final l in lugares) {
      porCategoria[l.categoria] = (porCategoria[l.categoria] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: colores.primaryContainer,
            child: Text(
              nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: colores.onPrimaryContainer,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(nombre,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        Text(email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place, size: 36, color: colores.primary),
                    const SizedBox(width: 12),
                    Text('${lugares.length}',
                        style: Theme.of(context).textTheme.displaySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(lugares.length == 1
                    ? 'lugar guardado'
                    : 'lugares guardados'),
                if (porCategoria.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final e in porCategoria.entries)
                        Chip(
                          avatar: Icon(iconoDeCategoria(e.key), size: 18),
                          label: Text('${e.key}: ${e.value}'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            secondary: Icon(oscuro ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Modo oscuro'),
            value: oscuro,
            onChanged: (v) => context.read<TemaProvider>().alternar(v),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => _confirmarCerrarSesion(context),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
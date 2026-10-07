import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/providers/pizza_provider.dart';
import 'package:pizzeria/presentation/screens/welcome_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final pizzas = ref.watch(pizzasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio (comprador)')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Hola, ${user?.fullName ?? ''} 🍕',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          pizzas.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (list) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pizzas encontradas: ${list.length}'),
                for (final p in list)
                  Text('• ${p.name} (${p.category}) - \$${p.price} - ${p.restaurantName}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Cerrar sesión',
            width: 200,
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (!context.mounted) return;
              CustomNavigator.pushAndRemoveUntilFade(
                  context, const WelcomeScreen());
            },
          ),
        ],
      ),
    );
  }
}
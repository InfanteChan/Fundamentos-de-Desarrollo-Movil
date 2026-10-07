import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/screens/welcome_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Panel del vendedor')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hola, ${user?.fullName ?? ''} 👨‍🍳',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text('Rol: ${user?.role ?? ''}'),
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
      ),
    );
  }
}
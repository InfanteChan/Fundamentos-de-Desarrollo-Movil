import 'package:flutter/material.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final Animation<double> _escala =
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colores.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _escala,
              child: Icon(Icons.place, size: 110, color: colores.onPrimary),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _ctrl,
              child: Text(
                'Mis Lugares Favoritos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colores.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
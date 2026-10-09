import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'core/tema.dart';
import 'providers/lugares_provider.dart';
import 'providers/tema_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LugaresProvider()),
        ChangeNotifierProvider(create: (_) => TemaProvider()..cargar()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final modo = context.watch<TemaProvider>().modo;
    return MaterialApp(
      title: 'Mis Lugares Favoritos',
      debugShowCheckedModeBanner: false,
      theme: AppTema.claro,
      darkTheme: AppTema.oscuro,
      themeMode: modo,
      home: const SplashScreen(),
    );
  }
}
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // Quita la etiqueta de debug para que se vea más limpio
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00897B)),
      ),
      home: const MyHomePage(title: 'Reserva de Viaje'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  void _resetForm() {
    setState(() {
      // Espacio para limpiar futuros campos
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tono verde oscuro característico para títulos e interfaz principal
    const mainGreen = Color(0xFF0D8A72);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Fondo de pantalla ligeramente gris para contrastar la tarjeta
      appBar: AppBar(
        backgroundColor: mainGreen, 
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Limpiar campos',
            onPressed: _resetForm, 
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TARJETA DE INFORMACIÓN GENERAL (DISEÑO FIEL A LA IMAGEN) ---
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F5), // Color gris claro de fondo
                borderRadius: BorderRadius.circular(28.0), // Esquinas sumamente redondeadas
                border: Border.all(color: const Color(0xFFE2E6E4), width: 1), // Borde suave exterior
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icono circular de información
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD2EDE8), // Fondo verde menta pastel
                            shape: BoxShape.circle,   // Forma completamente circular
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: mainGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        // Textos de Cabecera
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sección 1 · Información general',
                                style: TextStyle(
                                  color: mainGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2.0),
                              Text(
                                'Completa tu reserva paso a paso',
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Línea divisoria horizontal delgada
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(
                        color: Color(0xFFE0E0E0),
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    // Texto explicativo inferior de la tarjeta
                    const Text(
                      'Llena tus datos, elige destino y confirma tu viaje.',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Aquí puedes continuar agregando tus inputs o campos más abajo
          ],
        ),
      ),
    );
  }
}

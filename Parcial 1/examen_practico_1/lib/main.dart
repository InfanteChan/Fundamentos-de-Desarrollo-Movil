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
      debugShowCheckedModeBanner: false,
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
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }
  
  void _resetForm() {
    setState(() {
      _nombreController.clear();
      _correoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const mainGreen = Color(0xFF0D8A72);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F5),
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: const Color(0xFFE2E6E4), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD2EDE8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: mainGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14.0),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(
                        color: Color(0xFFE0E0E0),
                        thickness: 1,
                        height: 1,
                      ),
                    ),
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
            
            const SizedBox(height: 16.0),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F5),
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: const Color(0xFFE2E6E4), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD2EDE8),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: mainGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sección 2 · Datos del viajero',
                                style: TextStyle(
                                  color: mainGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2.0),
                              Text(
                                '¿Quién se va de viaje?',
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(
                        color: Color(0xFFE0E0E0),
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        hintText: 'Nombre completo',
                        hintStyle: const TextStyle(color: Colors.black45, fontSize: 16),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.person, color: mainGreen),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Correo electrónico',
                        hintStyle: const TextStyle(color: Colors.black45, fontSize: 16),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.email, color: mainGreen),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

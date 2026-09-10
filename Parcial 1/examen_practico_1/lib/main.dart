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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
        ),
      ),
      home: const MyHomePage(
        title: 'Reserva de Viaje',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const Color mainGreen = Color(0xFF0D8A72);
  static const Color sectionOrange = Color(0xFFE67E22);

  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color cardColor = Color(0xFFF4F6F5);
  static const Color cardBorderColor = Color(0xFFE2E6E4);

  final TextEditingController _nombreController =
      TextEditingController();

  final TextEditingController _correoController =
      TextEditingController();

  String _destinoSeleccionado = 'Playa';
  String _transporteSeleccionado = 'Avión';

  final List<String> _opcionesTransporte = [
    'Avión',
    'Autobús',
    'Tren',
    'Barco',
  ];

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
      _destinoSeleccionado = 'Playa';
      _transporteSeleccionado = 'Avión';
    });
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          textDirection: TextDirection.ltr,
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.cleaning_services_outlined,
            ),
            tooltip: 'Limpiar campos',
            onPressed: _resetForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInformacionGeneral(),
            const SizedBox(height: 16),
            _buildDatosViajero(),
            const SizedBox(height: 16),
            _buildDestinoYTransporte(),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionGeneral() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.info_outline,
            title: 'Sección 1 · Información general',
            subtitle: 'Completa tu reserva paso a paso',
            color: mainGreen,
            iconBackgroundColor: const Color(0xFFD2EDE8),
            circularIcon: true,
          ),
          _buildDivider(),
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
    );
  }

  Widget _buildDatosViajero() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_outline,
            title: 'Sección 2 · Datos del viajero',
            subtitle: '¿Quién se va de viaje?',
            color: mainGreen,
            iconBackgroundColor: const Color(0xFFD2EDE8),
          ),
          _buildDivider(),
          TextFormField(
            controller: _nombreController,
            decoration: _buildInputDecoration(
              hintText: 'Nombre completo',
              icon: Icons.person,
              color: mainGreen,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _correoController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              hintText: 'Correo electrónico',
              icon: Icons.email,
              color: mainGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinoYTransporte() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.location_on_outlined,
            title: 'Sección 3 · Destino y transporte',
            subtitle: 'Elige tu aventura',
            color: sectionOrange,
            iconBackgroundColor: const Color(0xFFFDEBD0),
          ),
          _buildDivider(),
          Row(
            children: [
              _buildDestinoCard(
                'Playa',
                Icons.umbrella_outlined,
                Colors.blue,
              ),
              const SizedBox(width: 10),
              _buildDestinoCard(
                'Ciudad',
                Icons.domain_outlined,
                Colors.orange,
              ),
              const SizedBox(width: 10),
              _buildDestinoCard(
                'Montaña',
                Icons.terrain_outlined,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Transporte:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _transporteSeleccionado,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.directions_bus,
                color: sectionOrange,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            items: _opcionesTransporte.map(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            onChanged: (String? newValue) {
              if (newValue == null) {
                return;
              }

              setState(() {
                _transporteSeleccionado = newValue;
              });

              _mostrarSnackBar(
                'Transporte seleccionado: $newValue',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: cardBorderColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconBackgroundColor,
    bool circularIcon = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            shape: circularIcon
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius: circularIcon
                ? null
                : BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        height: 1,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    required Color color,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.black45,
        fontSize: 16,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(
        icon,
        color: color,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildDestinoCard(
    String tipo,
    IconData icon,
    Color color,
  ) {
    final bool isSelected =
        _destinoSeleccionado == tipo;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE1F5FE)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : cardBorderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              _destinoSeleccionado = tipo;
            });

            _mostrarSnackBar(
              'Destino seleccionado: $tipo',
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.blue
                      : color,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  tipo,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.blue
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
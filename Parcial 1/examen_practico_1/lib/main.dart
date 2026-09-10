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
  static const Color sectionPurple = Color(0xFF9B59B6);

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

  bool _hotelIncluido = false;
  bool _tourGuiado = false;
  bool _seguroViaje = false;

  bool _notificaciones = true;

  double _presupuesto = 3000;

  DateTime? _fechaViaje;

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

      _hotelIncluido = false;
      _tourGuiado = false;
      _seguroViaje = false;

      _notificaciones = true;
      _presupuesto = 3000;
      _fechaViaje = null;
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

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _fechaViaje) {
      setState(() {
        _fechaViaje = picked;
      });

      _mostrarSnackBar(
        'Fecha seleccionada: '
        '${picked.day}/${picked.month}/${picked.year}',
      );
    }
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

            const SizedBox(height: 16),

            _buildExtrasYPreferencias(),

            const SizedBox(height: 16),

            _buildConfirmar(),
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
                Icons.beach_access,
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

  Widget _buildExtrasYPreferencias() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.tune,
            title: 'Sección 4 · Extras y preferencias',
            subtitle: 'Personaliza tu experiencia',
            color: sectionPurple,
            iconBackgroundColor: const Color(0xFFF5EEF8),
          ),
          _buildDivider(),
          _buildExtraItem(
            'Hotel incluido',
            '+ \$1200',
            Icons.hotel,
            _hotelIncluido,
            (value) {
              setState(() {
                _hotelIncluido = value;
              });

              _mostrarSnackBar(
                'Hotel incluido: '
                '${value ? "Activado" : "Desactivado"}',
              );
            },
          ),
          const SizedBox(height: 12),
          _buildExtraItem(
            'Tour guiado',
            '+ \$600',
            Icons.flag,
            _tourGuiado,
            (value) {
              setState(() {
                _tourGuiado = value;
              });

              _mostrarSnackBar(
                'Tour guiado: '
                '${value ? "Activado" : "Desactivado"}',
              );
            },
          ),
          const SizedBox(height: 12),
          _buildExtraItem(
            'Seguro de viaje',
            '+ \$400',
            Icons.shield,
            _seguroViaje,
            (value) {
              setState(() {
                _seguroViaje = value;
              });

              _mostrarSnackBar(
                'Seguro de viaje: '
                '${value ? "Activado" : "Desactivado"}',
              );
            },
          ),
          const SizedBox(height: 16),
          _buildNotificaciones(),
          const SizedBox(height: 16),
          _buildPresupuesto(),
          const SizedBox(height: 16),
          _buildFechaViaje(),
        ],
      ),
    );
  }

  Widget _buildNotificaciones() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EEF8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SwitchListTile(
        title: const Text(
          'Recibir notificaciones',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _notificaciones
              ? 'Activadas'
              : 'Desactivadas',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: _notificaciones,
        activeThumbColor: Colors.white,
        activeTrackColor: sectionPurple,
        onChanged: (bool value) {
          setState(() {
            _notificaciones = value;
          });

          _mostrarSnackBar(
            'Notificaciones: '
            '${value ? "Activadas" : "Desactivadas"}',
          );
        },
      ),
    );
  }

  Widget _buildPresupuesto() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF9EBEF),
            Color(0xFFE8F8F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Presupuesto:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: sectionPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${_presupuesto.toInt()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _presupuesto,
            min: 500,
            max: 10000,
            divisions: 20,
            activeColor: sectionPurple,
            inactiveColor: cardBorderColor,
            onChanged: (double value) {
              setState(() {
                _presupuesto = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFechaViaje() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: sectionPurple.withAlpha(100),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EEF8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.calendar_month,
            color: sectionPurple,
            size: 24,
          ),
        ),
        title: const Text(
          'Fecha del viaje',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black38,
          ),
        ),
        subtitle: Text(
          _fechaViaje == null
              ? 'Toca para elegir fecha'
              : '${_fechaViaje!.day}/'
                '${_fechaViaje!.month}/'
                '${_fechaViaje!.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black38,
        ),
        onTap: () => _seleccionarFecha(context),
      ),
    );
  }

  Widget _buildConfirmar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mainGreen,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sección 5 · Confirmar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa tus datos antes de despegar. ✈️',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _mostrarSnackBar(
                      'Mostrando resumen de la reserva',
                    );
                  },
                  icon: const Icon(
                    Icons.visibility,
                    color: mainGreen,
                  ),
                  label: const Text(
                    'Ver Resumen',
                    style: TextStyle(
                      color: mainGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: mainGreen,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _mostrarSnackBar(
                      '¡Reserva confirmada!',
                    );
                  },
                  icon: const Icon(
                    Icons.flight_takeoff,
                    color: Colors.black87,
                  ),
                  label: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtraItem(
    String titulo,
    String precio,
    IconData icon,
    bool variable,
    Function(bool) alCambiar,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorderColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.black45,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          precio,
          style: const TextStyle(
            color: Colors.black38,
          ),
        ),
        trailing: Checkbox(
          value: variable,
          activeColor: sectionPurple,
          onChanged: (bool? value) {
            alCambiar(value ?? false);
          },
        ),
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
}

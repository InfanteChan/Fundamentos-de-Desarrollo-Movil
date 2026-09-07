import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Preferencias',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegistroPreferenciasScreen(),
    );
  }
}

class RegistroPreferenciasScreen extends StatelessWidget {
  const RegistroPreferenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Preferencias', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5), // Un gris claro limpio de fondo
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          // SECCIÓN 1
          _buildSectionCard(
            color: const Color(0xFFE3F2FD), // Azul muy claro
            borderColor: Colors.blue.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.info_outline, 'Seccion 1: Informacion General', Colors.blue),
                const SizedBox(height: 8),
                const Text(
                  'Completa los siguientes datos personales basicos', 
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // SECCIÓN 2
          _buildSectionCard(
            color: const Color(0xFFE8F5E9), // Verde muy claro
            borderColor: Colors.green.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.person_outline, 'Seccion 2: Datos Personales', Colors.green),
                const SizedBox(height: 12),
                _buildMockTextField(Icons.person, 'Nombre completo'),
                const SizedBox(height: 10),
                _buildMockTextField(Icons.calendar_today_outlined, 'Edad'),
              ],
            ),
          ),

          // SECCIÓN 3
          _buildSectionCard(
            color: const Color(0xFFFFF3E0), // Naranja muy claro
            borderColor: Colors.orange.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.view_quilt, 'Seccion 3: Distribucion en Filas', Colors.orange),
                const SizedBox(height: 12),
                _buildColorRow(Colors.red, const Color(0xFFFFEBEE), 'Fila 1 - Color Rojo'),
                const SizedBox(height: 8),
                _buildColorRow(Colors.yellow.shade700, const Color(0xFFFFFDE7), 'Fila 2 - Color Amarillo'),
                const SizedBox(height: 8),
                _buildColorRow(Colors.blue, const Color(0xFFE3F2FD), 'Fila 3 - Color Azul'),
              ],
            ),
          ),

          // SECCIÓN 4
          _buildSectionCard(
            color: const Color(0xFFF3E5F5), // Morado muy claro
            borderColor: Colors.purple.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.grid_on, 'Seccion 4: Cuatro Hijos en Colores', Colors.purple),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildColorBox('Hijo 1', const Color(0xFFE91E63), const Color(0xFFFCE4EC)),
                    _buildColorBox('Hijo 2', const Color(0xFFFF9800), const Color(0xFFFFF3E0)),
                    _buildColorBox('Hijo 3', const Color(0xFF4CAF50), const Color(0xFFE8F5E9)),
                    _buildColorBox('Hijo 4', const Color(0xFF9C27B0), const Color(0xFFF3E5F5)),
                  ],
                ),
              ],
            ),
          ),

          // SECCIÓN 5
          _buildSectionCard(
            color: const Color(0xFFFAFAFA), // Gris neutro claro
            borderColor: Colors.grey.shade300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.add_circle_outline, 'Seccion 5: Controles UI', Colors.grey.shade700),
                const SizedBox(height: 12),
                
                const Text('Genero:', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildMockRadio(true, 'Masculino'),
                _buildMockRadio(false, 'Femenino'),
                _buildMockRadio(false, 'Otro'),
                
                const SizedBox(height: 12),
                const Text('Intereses:', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildMockCheckbox(false, 'Deporte'),
                _buildMockCheckbox(false, 'Musica'),
                _buildMockCheckbox(false, 'Cine'),
                _buildMockCheckbox(false, 'Lectura'),

                const SizedBox(height: 12),
                const Text('Pais:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildMockDropdown(),
              ],
            ),
          ),

          // BOTONES FINALES
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, 
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.visibility),
                    label: const Text('Mostrar Preferencias', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Guardar Registro', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES REFACTORIZADOS Y CORREGIDOS ---

  Widget _buildSectionCard({required Color color, required Color borderColor, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // CORREGIDO AQUÍ (Uso de 'only')
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildMockTextField(IconData icon, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(hint, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildColorRow(Color dotColor, Color bgColor, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildColorBox(String text, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildMockRadio(bool selected, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // CORREGIDO AQUÍ (Uso de 'symmetric')
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? Colors.purple : Colors.grey,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildMockCheckbox(bool checked, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // CORREGIDO AQUÍ (Uso de 'symmetric')
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,color: Colors.grey,size: 22,),
            const SizedBox(width: 12),
            Text(text),
        ],
      ),
    );
  }
  
  Widget _buildMockDropdown() 
  {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade400),
    ),
    child: 
    const Row(mainAxisAlignment: 
    MainAxisAlignment.spaceBetween,children: 
      [
        Row(
          children: 
          [
            Icon
            (
              Icons.public, 
              color: Colors.grey, 
              size: 20),
            SizedBox(width: 12),
            Text('Mexico'),
         ],
       ),
       Icon (
            Icons.arrow_drop_down, 
            color: Colors.grey),
      ],
      ),
    );
  }
}
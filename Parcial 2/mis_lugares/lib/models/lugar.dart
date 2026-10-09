class Lugar {
  final String? id;
  final String nombre;
  final String? descripcion;
  final String categoria;
  final double latitud;
  final double longitud;
  final String? fotoUrl;

  const Lugar({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.categoria,
    required this.latitud,
    required this.longitud,
    this.fotoUrl,
  });

  factory Lugar.fromMap(Map<String, dynamic> m) => Lugar(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        descripcion: m['descripcion'] as String?,
        categoria: m['categoria'] as String,
        latitud: (m['latitud'] as num).toDouble(),
        longitud: (m['longitud'] as num).toDouble(),
        fotoUrl: m['foto_url'] as String?,
      );

  /// Sin id ni user_id: Supabase los llena solos.
  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'categoria': categoria,
        'latitud': latitud,
        'longitud': longitud,
        'foto_url': fotoUrl,
      };
}
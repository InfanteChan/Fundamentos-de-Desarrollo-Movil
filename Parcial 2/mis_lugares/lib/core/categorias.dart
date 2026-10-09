import 'package:flutter/material.dart';

const Map<String, IconData> categorias = {
  'Comida': Icons.restaurant,
  'Estudio': Icons.school,
  'Diversión': Icons.celebration,
  'Deporte': Icons.fitness_center,
  'Casa': Icons.home,
  'Otro': Icons.place,
};

IconData iconoDeCategoria(String categoria) =>
    categorias[categoria] ?? Icons.place;
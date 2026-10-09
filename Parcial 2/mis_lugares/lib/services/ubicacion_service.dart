import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class UbicacionException implements Exception {
  final String mensaje;
  const UbicacionException(this.mensaje);
}

class UbicacionService {
  /// Devuelve la ubicación actual o lanza una [UbicacionException] con un mensaje claro.
  Future<LatLng> obtenerActual() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      throw const UbicacionException('Activa la ubicación (GPS) de tu dispositivo.');
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      throw const UbicacionException('Permiso de ubicación denegado.');
    }
    if (permiso == LocationPermission.deniedForever) {
      throw const UbicacionException(
          'El permiso de ubicación está bloqueado. Actívalo en la configuración.');
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LatLng(pos.latitude, pos.longitude);
  }
}
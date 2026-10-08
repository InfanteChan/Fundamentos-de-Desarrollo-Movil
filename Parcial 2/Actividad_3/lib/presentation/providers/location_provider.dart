import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationNotifier extends AsyncNotifier<LatLng> {
  static const LatLng defaultLocation = LatLng(19.432608, -99.133209);

  @override
  Future<LatLng> build() => _determinePosition();

  Future<LatLng> _determinePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return defaultLocation;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return defaultLocation;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return defaultLocation;
    }
  }

  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_determinePosition);
  }
}

final userLocationProvider =
    AsyncNotifierProvider<LocationNotifier, LatLng>(LocationNotifier.new);
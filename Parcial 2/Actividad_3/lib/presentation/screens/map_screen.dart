import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:pizzeria/models/restaurant_model.dart';
import 'package:pizzeria/presentation/providers/location_provider.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  RestaurantModel? _selected;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _select(RestaurantModel restaurant) {
    setState(() => _selected = restaurant);
    _mapController.move(LatLng(restaurant.latitude, restaurant.longitude), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Pizzerías Cercanas', showBackButton: false),
      body: locationAsync.when(
        loading: () => const Center(child: DashedOvenLoader()),
        error: (err, _) => Center(child: Text('Error al obtener ubicación: $err')),
        data: (userPos) => restaurantsAsync.when(
          loading: () => const Center(child: DashedOvenLoader()),
          error: (err, _) => Center(child: Text('Error al cargar el mapa: $err')),
          data: (restaurants) => Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userPos,
                  initialZoom: 13.5,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.pizzeria.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: userPos,
                        width: 60,
                        height: 60,
                        child: const _UserMarker(),
                      ),
                      for (final restaurant in restaurants)
                        Marker(
                          point: LatLng(restaurant.latitude, restaurant.longitude),
                          width: 80,
                          height: 70,
                          child: GestureDetector(
                            onTap: () => _select(restaurant),
                            child: _RestaurantMarker(name: restaurant.name),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: 'gps_fab_map',
                  backgroundColor: AppColors.cardBackground,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    ref.read(userLocationProvider.notifier).refreshLocation();
                    _mapController.move(userPos, 14.5);
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _selected == null
                    ? const _MapHint()
                    : _RestaurantCard(
                        restaurant: _selected!,
                        onClose: () => setState(() => _selected = null),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.person_pin, color: Colors.white, size: 22),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Tú',
            style: TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _RestaurantMarker extends StatelessWidget {
  final String name;

  const _RestaurantMarker({required this.name});

  @override
  Widget build(BuildContext context) {
    final label = name.length > 10 ? '${name.substring(0, 8)}..' : name;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.local_pizza, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapHint extends StatelessWidget {
  const _MapHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.touch_app_outlined, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Toca cualquier pizzería en el mapa para ver su información y ubicación.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onClose;

  const _RestaurantCard({required this.restaurant, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final imageUrl = restaurant.imageUrl.isNotEmpty
        ? restaurant.imageUrl
        : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 68,
                    height: 68,
                    color: AppColors.inputBackground,
                    child: const Icon(Icons.storefront, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.address,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (restaurant.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.phone,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textLight),
                onPressed: onClose,
              ),
            ],
          ),
          if (restaurant.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              restaurant.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
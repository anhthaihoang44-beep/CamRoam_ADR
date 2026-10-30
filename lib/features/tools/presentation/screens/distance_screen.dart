import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haversine_calc.dart';

class DistanceScreen extends ConsumerStatefulWidget {
  const DistanceScreen({super.key});

  @override
  ConsumerState<DistanceScreen> createState() => _DistanceScreenState();
}

class _DistanceScreenState extends ConsumerState<DistanceScreen> {
  final List<GeoPoint> _points = [];
  bool _inMiles = false;

  double get _totalKm {
    if (_points.length < 2) return 0;
    return HaversineCalc.routeDistanceKm(_points);
  }

  String get _distanceText {
    if (_points.length < 2) return '—';
    return HaversineCalc.format(_totalKm, inMiles: _inMiles, decimals: 2);
  }

  Future<void> _addCurrentLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        setState(() {
          _points.add(GeoPoint(pos.latitude, pos.longitude));
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Distance Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _inMiles = !_inMiles),
            child: Text(
              _inMiles ? 'mi → km' : 'km → mi',
              style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold),
            ),
          ),
          if (_points.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _points.clear()),
              child: const Text('Clear', style: TextStyle(color: AppColors.liveRed)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _points.isNotEmpty
                    ? LatLng(_points.last.latitude, _points.last.longitude)
                    : const LatLng(21, 105),
                initialZoom: _points.isEmpty ? 3 : 7,
                onTap: (tapPosition, latLng) {
                  setState(() {
                    _points.add(GeoPoint(latLng.latitude, latLng.longitude));
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.camroam.app',
                ),
                if (_points.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
                        color: AppColors.cyan,
                        strokeWidth: 3.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _points.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    return Marker(
                      width: 36,
                      height: 36,
                      point: LatLng(p.latitude, p.longitude),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == 0 ? AppColors.cyan : AppColors.emerald,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Bottom panel
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            color: AppColors.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Distance', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(
                          _distanceText,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${_points.length} point${_points.length != 1 ? 's' : ''}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _addCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 16),
                          label: const Text('My Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap map to add points',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


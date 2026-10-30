import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/webcam_model.dart';
import '../controllers/live_controller.dart';

class GlobalMapScreen extends ConsumerStatefulWidget {
  const GlobalMapScreen({super.key});

  @override
  ConsumerState<GlobalMapScreen> createState() => _GlobalMapScreenState();
}

class _GlobalMapScreenState extends ConsumerState<GlobalMapScreen> {
  WebcamModel? _selected;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final liveFeed = ref.watch(liveFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Global Street Webcams'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 3,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(20, 0),
                initialZoom: 2.0,
                minZoom: 1.5,
                maxZoom: 17,
              ),
              children: [
                // Satellite-style dark tiles
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.camroam.app',
                ),

                // Webcam Markers
                MarkerLayer(
                  markers: liveFeed.allWebcams.map((cam) {
                    final isSelected = _selected?.id == cam.id;
                    return Marker(
                      width: isSelected ? 60 : 48,
                      height: isSelected ? 60 : 48,
                      point: LatLng(cam.latitude, cam.longitude),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selected = cam);
                          _mapController.move(
                            LatLng(cam.latitude, cam.longitude),
                            8,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.cyan : AppColors.liveRed,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isSelected ? AppColors.cyan : AppColors.liveRed)
                                    .withOpacity(0.5),
                                blurRadius: isSelected ? 12 : 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              cam.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceCard,
                                child: const Icon(Icons.videocam, color: AppColors.cyan, size: 22),
                              ),
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

          // Bottom webcam strip
          Container(
            height: 130,
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.liveRed,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live Worldwide – Tap locations to explore',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: liveFeed.allWebcams.length,
                    itemBuilder: (context, index) {
                      final cam = liveFeed.allWebcams[index];
                      final isSelected = _selected?.id == cam.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selected = cam);
                          _mapController.move(LatLng(cam.latitude, cam.longitude), 9);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 130,
                          margin: const EdgeInsets.only(right: 10, bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.cyan : AppColors.borderSubtle,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(cam.thumbnailUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceCard)),
                              if (cam.isHot)
                                const Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Text('🔥', style: TextStyle(fontSize: 14)),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  color: Colors.black.withOpacity(0.6),
                                  child: Text(
                                    cam.city,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: _selected != null
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.cyan,
              foregroundColor: Colors.black,
              onPressed: () => context.push('/live-player', extra: _selected),
              icon: const Icon(Icons.play_circle_filled_rounded),
              label: Text(
                _selected!.city,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}


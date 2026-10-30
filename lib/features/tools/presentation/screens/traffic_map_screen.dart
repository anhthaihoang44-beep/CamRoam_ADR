import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';

class TrafficMapScreen extends StatelessWidget {
  const TrafficMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Traffic Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: AppColors.cyan),
            tooltip: 'Open in Google Maps',
            onPressed: () async {
              final uri = Uri.parse('https://www.google.com/maps/@?api=1&map_action=map&layer=traffic');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(21.0285, 105.8542),
                initialZoom: 5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.camroam.app',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            color: AppColors.surface,
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tap "Open in Google Maps" above for real-time traffic layer.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse('https://www.google.com/maps/@?api=1&map_action=map&layer=traffic');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.liveRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Open Traffic', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


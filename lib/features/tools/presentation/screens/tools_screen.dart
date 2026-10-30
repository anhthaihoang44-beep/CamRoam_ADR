import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            children: [
              TextSpan(text: 'Geo '),
              TextSpan(text: 'Toolkit', style: TextStyle(color: AppColors.cyan)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Traffic Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.liveRed.withOpacity(0.7), AppColors.hotOrange.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.traffic_rounded, size: 44, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Traffic',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Real-time traffic on the map',
                          style: TextStyle(color: Colors.white70, fontSize: 12.5),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => context.push('/traffic'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.liveRed,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Open Traffic Map',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2x2 Tool Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ToolCard(
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.cyan,
                  title: 'GPS Camera',
                  subtitle: 'Stamp coordinates on photos',
                  onTap: () => context.push('/gps-camera'),
                ),
                _ToolCard(
                  icon: Icons.explore_rounded,
                  color: AppColors.emerald,
                  title: 'Digital Compass',
                  subtitle: 'Real-time magnetic heading',
                  onTap: () => context.push('/compass'),
                ),
                _ToolCard(
                  icon: Icons.social_distance_rounded,
                  color: const Color(0xFF7C4DFF),
                  title: 'Distance Calc',
                  subtitle: 'Haversine great-circle route',
                  onTap: () => context.push('/distance'),
                ),
                _ToolCard(
                  icon: Icons.photo_library_rounded,
                  color: AppColors.hotOrange,
                  title: 'Photo History',
                  subtitle: 'Your GPS photo journal',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.3,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


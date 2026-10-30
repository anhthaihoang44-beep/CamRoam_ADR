import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/passport_stamp.dart';
import '../controllers/roam_controller.dart';

class PassportScreen extends ConsumerWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stamps = ref.watch(roamProvider).stamps;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            children: [
              TextSpan(text: 'Landmark '),
              TextSpan(text: 'Passport', style: TextStyle(color: AppColors.cyan)),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: stamps.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📖', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 14),
                  const Text(
                    'Your passport is empty',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore 360° views or take GPS photos\nat landmarks to earn stamps!',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/panorama'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.threesixty_rounded),
                    label: const Text('Explore 360°', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: stamps.length,
              itemBuilder: (context, i) {
                final stamp = stamps[i];
                return _StampCard(stamp: stamp);
              },
            ),
    );
  }
}

class _StampCard extends StatelessWidget {
  final PassportStamp stamp;
  const _StampCard({required this.stamp});

  String get _sourceIcon {
    switch (stamp.source) {
      case StampSource.liveWebcamView: return '📡';
      case StampSource.gpsCameraCapture: return '📸';
      case StampSource.roam360: return '🌐';
      case StampSource.manualDiscovery: return '🔎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceCard, AppColors.surfaceLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(_sourceIcon, style: const TextStyle(fontSize: 28)),
            ),

            // Title & location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stamp.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
                Text(
                  stamp.city,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),

            // Date & visit count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stamp.unlockedAt.day}/${stamp.unlockedAt.month}/${stamp.unlockedAt.year}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '×${stamp.visitCount}',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


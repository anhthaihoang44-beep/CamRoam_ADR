import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../controllers/roam_controller.dart';

class RoamScreen extends ConsumerWidget {
  const RoamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roamState = ref.watch(roamProvider);
    final daily = roamState.dailyDiscovery;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            children: [
              TextSpan(text: 'Explore '),
              TextSpan(text: '& Roam', style: TextStyle(color: AppColors.emerald)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 360° Street View Card
            _BigFeatureCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2137), Color(0xFF1A3A55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.threesixty_rounded,
              iconColor: AppColors.cyan,
              badgeText: '360°',
              title: 'Street View',
              subtitle: 'Tap to wander the streets',
              buttonText: 'Explore Map',
              onTap: () => context.push('/panorama'),
              onButton: () => context.push('/panorama'),
            ),

            const SizedBox(height: 14),

            // 3D Earth Card
            _BigFeatureCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A1F3D), Color(0xFF152E50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.public_rounded,
              iconColor: AppColors.emerald,
              badgeText: '3D',
              title: '3D Earth',
              subtitle: 'Spin the globe, explore anywhere',
              buttonText: 'Launch Globe',
              onTap: () => context.push('/earth3d'),
              onButton: () => context.push('/earth3d'),
            ),

            const SizedBox(height: 14),

            // Daily Discovery Card
            if (daily != null)
              GlassCard(
                onTap: () => context.push('/panorama', extra: daily),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: AppColors.surfaceLight,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        daily.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.landscape_rounded,
                          color: AppColors.textMuted,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '✨ Daily Discovery',
                              style: TextStyle(
                                color: AppColors.emerald,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            daily.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${daily.city}, ${daily.country}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.cyan),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // Landmark Passport Card
            GlassCard(
              onTap: () => context.push('/passport'),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purpleGlow.withOpacity(0.8),
                          AppColors.cyan.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.book_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Landmark Passport',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${roamState.stamps.length} stamps collected',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.cyan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigFeatureCard extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final Color iconColor;
  final String badgeText;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;
  final VoidCallback onButton;

  const _BigFeatureCard({
    required this.gradient,
    required this.icon,
    required this.iconColor,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
    required this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 155,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: iconColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(blurRadius: 8, color: iconColor.withOpacity(0.3)),
                            ],
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: onButton,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: iconColor,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(icon, size: 60, color: iconColor.withOpacity(0.7)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


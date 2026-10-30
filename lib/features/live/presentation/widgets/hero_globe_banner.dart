import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/live_badge.dart';

class HeroGlobeBanner extends StatefulWidget {
  final VoidCallback onExploreMap;

  const HeroGlobeBanner({
    super.key,
    required this.onExploreMap,
  });

  @override
  State<HeroGlobeBanner> createState() => _HeroGlobeBannerState();
}

class _HeroGlobeBannerState extends State<HeroGlobeBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void disposeWidget() {
    _rotationController.dispose();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F1E36),
            Color(0xFF0A1324),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.cyan.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background subtle cosmic star dots
          Positioned(
            right: 10,
            top: 10,
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.cyan.withOpacity(0.35),
                          AppColors.purpleGlow.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cyan.withOpacity(0.4),
                            width: 1.5,
                          ),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D253F), Color(0xFF144D6B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.public,
                          size: 60,
                          color: AppColors.cyan,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Foreground Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const LiveBadge(),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '60+ Live Views',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: 'Live '),
                    TextSpan(
                      text: 'Global Views',
                      style: TextStyle(color: AppColors.cyan),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const SizedBox(
                width: 200,
                child: Text(
                  'Stream real-time cameras from 30+ countries across the globe.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.onExploreMap,
                icon: const Icon(Icons.map_rounded, size: 16, color: Colors.black),
                label: const Text(
                  'Explore Map',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


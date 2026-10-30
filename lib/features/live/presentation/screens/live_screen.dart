import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../controllers/live_controller.dart';
import '../widgets/hero_globe_banner.dart';
import '../widgets/webcam_card.dart';
import '../widgets/category_chips.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  final List<String> _categories = const [
    'All',
    'Skyline',
    'Beach',
    'Traffic',
    'Historic',
    'Mountain',
    'Nature',
  ];

  @override
  void initState() {
    super.initState();
    _requestNearbyLocation();
  }

  Future<void> _requestNearbyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        ref.read(liveFeedProvider.notifier).updateNearbyWebcams(pos.latitude, pos.longitude);
      }
    } catch (_) {
      // Graceful fallback to default popular webcams
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveFeedProvider);
    final notifier = ref.read(liveFeedProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.cyanGradient,
              ),
              child: const Icon(Icons.travel_explore, size: 20, color: Colors.black),
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(text: 'Roam'),
                  TextSpan(
                    text: 'Cam',
                    style: TextStyle(color: AppColors.cyan),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: liveState.isLoading
          ? _buildLoadingSkeleton()
          : liveState.errorMessage != null
              ? ErrorRetryView(
                  message: liveState.errorMessage!,
                  onRetry: () => notifier.loadFeed(),
                )
              : RefreshIndicator(
                  color: AppColors.cyan,
                  backgroundColor: AppColors.surfaceCard,
                  onRefresh: () async => notifier.loadFeed(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Globe Banner
                        HeroGlobeBanner(
                          onExploreMap: () => context.push('/map-webcams'),
                        ),

                        const SizedBox(height: 16),

                        // Section 1: Live Worldwide
                        _buildSectionHeader(
                          title: 'Live Worldwide',
                          onSeeAll: () => context.push('/map-webcams'),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: liveState.allWebcams.length.clamp(0, 15),
                            itemBuilder: (context, index) {
                              final cam = liveState.allWebcams[index];
                              return WebcamCard(
                                webcam: cam,
                                isFavorite: notifier.isFavorite(cam.id),
                                onToggleFavorite: () => notifier.toggleFavorite(cam.id),
                                onTap: () => context.push('/live-player', extra: cam),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section 2: Live Near You
                        _buildSectionHeader(
                          title: 'Live Near You',
                          onSeeAll: () => context.push('/map-webcams'),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: liveState.nearbyWebcams.length,
                            itemBuilder: (context, index) {
                              final cam = liveState.nearbyWebcams[index];
                              return WebcamCard(
                                webcam: cam,
                                isFavorite: notifier.isFavorite(cam.id),
                                onToggleFavorite: () => notifier.toggleFavorite(cam.id),
                                onTap: () => context.push('/live-player', extra: cam),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section 3: Categories & Filtered Webcams
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: const [
                              Text(
                                'Explore Categories',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        CategoryChips(
                          categories: _categories,
                          selectedCategory: liveState.selectedCategory,
                          onSelect: (cat) => notifier.selectCategory(cat),
                        ),
                        const SizedBox(height: 14),

                        // Category webcams horizontal scroll
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: liveState.filteredWebcams.length,
                            itemBuilder: (context, index) {
                              final cam = liveState.filteredWebcams[index];
                              return WebcamCard(
                                webcam: cam,
                                isFavorite: notifier.isFavorite(cam.id),
                                onToggleFavorite: () => notifier.toggleFavorite(cam.id),
                                onTap: () => context.push('/live-player', extra: cam),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.cyan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonLoader(width: double.infinity, height: 180, borderRadius: 24),
          SizedBox(height: 24),
          SkeletonLoader(width: 160, height: 24),
          SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 180, borderRadius: 20),
          SizedBox(height: 24),
          SkeletonLoader(width: 140, height: 24),
          SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 180, borderRadius: 20),
        ],
      ),
    );
  }
}


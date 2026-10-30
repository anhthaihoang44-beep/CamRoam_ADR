import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/landmark_model.dart';
import '../../domain/entities/passport_stamp.dart';
import '../controllers/roam_controller.dart';

class Panorama360Screen extends ConsumerStatefulWidget {
  final LandmarkModel? landmark;

  const Panorama360Screen({super.key, this.landmark});

  @override
  ConsumerState<Panorama360Screen> createState() => _Panorama360ScreenState();
}

class _Panorama360ScreenState extends ConsumerState<Panorama360Screen> {
  late LandmarkModel _current;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    final roamState = ref.read(roamProvider);
    _current = widget.landmark ??
        (roamState.landmarks.isNotEmpty ? roamState.landmarks.first : _fallbackLandmark());
    _tryGiveStamp();

    // Fade out touch gesture hint after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  LandmarkModel _fallbackLandmark() {
    return LandmarkModel(
      id: 'default',
      name: 'Eiffel Tower',
      city: 'Paris',
      country: 'France',
      latitude: 48.8584,
      longitude: 2.2945,
      category: 'Monument',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800&auto=format&fit=crop&q=80',
      panorama360Url:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1600&auto=format&fit=crop&q=80',
      badgeIcon: 'tower',
      description: 'The world-famous iron lattice tower on the Champ de Mars, constructed in 1889.',
    );
  }

  void _tryGiveStamp() {
    final notifier = ref.read(roamProvider.notifier);
    final isNew = notifier.unlockStamp(_current, StampSource.roam360);
    if (isNew && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('🏆 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    'Collected stamp: ${_current.name}!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roamState = ref.watch(roamProvider);
    final activeUrl = _current.panorama360Url.isNotEmpty
        ? _current.panorama360Url
        : _current.thumbnailUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_rounded, color: Colors.white, size: 18),
            ),
            tooltip: 'View on Google Maps',
            onPressed: () async {
              final uri = Uri.parse(
                  'https://maps.google.com/?q=${_current.latitude},${_current.longitude}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 360 Viewer
          Positioned.fill(
            child: PanoramaViewer(
              key: ValueKey(_current.id),
              sensorControl: SensorControl.orientation,
              child: Image.network(
                activeUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.cyan,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                : null,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Loading 360° view...',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                errorBuilder: (_, error, __) {
                  // Fallback to high quality thumbnail if panorama URL has any issue
                  return Image.network(
                    _current.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.background,
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded, size: 64, color: AppColors.textMuted),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 360 Drag Interaction Hint Overlay
          if (_showHint)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showHint ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.touch_app_rounded, color: AppColors.cyan, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Swipe to explore 360°',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Info & Landmark Carousel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.92)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _current.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 13, color: AppColors.cyan),
                                const SizedBox(width: 4),
                                Text(
                                  '${_current.city}, ${_current.country}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.threesixty_rounded, color: AppColors.cyan, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '360° View',
                              style: TextStyle(
                                color: AppColors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_current.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _current.description,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Horizontal Landmark Switcher
                  SizedBox(
                    height: 64,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: roamState.landmarks.length,
                      itemBuilder: (ctx, i) {
                        final lm = roamState.landmarks[i];
                        final isSelected = lm.id == _current.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _current = lm;
                              _showHint = true;
                            });
                            _tryGiveStamp();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 80,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.cyan : Colors.white24,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  lm.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceCard),
                                ),
                                Container(
                                  color: isSelected
                                      ? AppColors.cyan.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.25),
                                ),
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  right: 4,
                                  child: Text(
                                    lm.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }
}

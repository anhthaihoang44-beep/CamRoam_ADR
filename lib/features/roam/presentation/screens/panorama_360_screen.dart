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
  bool _stampGiven = false;

  @override
  void initState() {
    super.initState();
    final roamState = ref.read(roamProvider);
    _current = widget.landmark ?? (roamState.landmarks.isNotEmpty ? roamState.landmarks.first : _fallbackLandmark());
    _tryGiveStamp();
  }

  LandmarkModel _fallbackLandmark() {
    return LandmarkModel(
      id: 'default',
      name: 'World',
      city: 'Earth',
      country: '',
      latitude: 0,
      longitude: 0,
      category: 'Nature',
      thumbnailUrl: '',
      panorama360Url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Equirectangular_projection_SW.jpg/1280px-Equirectangular_projection_SW.jpg',
      badgeIcon: 'world',
      description: 'Explore the world',
    );
  }

  void _tryGiveStamp() {
    final notifier = ref.read(roamProvider.notifier);
    final isNew = notifier.unlockStamp(_current, StampSource.roam360);
    if (isNew && mounted) {
      Future.delayed(const Duration(milliseconds: 400), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Text('🏆 '),
              Text('New stamp: ${_current.name}!', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            backgroundColor: AppColors.emerald.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _stampGiven = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roamState = ref.watch(roamProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: const Icon(Icons.map_rounded, color: Colors.white, size: 18),
            ),
            tooltip: 'Open in Maps',
            onPressed: () async {
              final uri = Uri.parse('https://maps.google.com/?q=${_current.latitude},${_current.longitude}');
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _current.panorama360Url.isNotEmpty
                ? PanoramaViewer(
                    child: Image.network(
                      _current.panorama360Url,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.cyan,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                const Text('Loading 360° panorama...', style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          ),
                    ),
                  )
                : Container(
                    color: AppColors.background,
                    child: const Center(
                      child: Icon(Icons.threesixty_rounded, size: 80, color: AppColors.textMuted),
                    ),
                  ),
          ),

          // Bottom info & landmarks strip
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            color: AppColors.surface,
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
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_current.city}, ${_current.country}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.threesixty_rounded, color: AppColors.cyan, size: 16),
                          SizedBox(width: 4),
                          Text('360°', style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Thumbnail strip
                SizedBox(
                  height: 72,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: roamState.landmarks.length,
                    itemBuilder: (ctx, i) {
                      final lm = roamState.landmarks[i];
                      final isSelected = lm.id == _current.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _current = lm);
                          _tryGiveStamp();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 90,
                          margin: const EdgeInsets.only(right: 10, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.cyan : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(lm.thumbnailUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceCard)),
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
    );
  }
}


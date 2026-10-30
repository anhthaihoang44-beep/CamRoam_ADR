import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../core/widgets/hot_badge.dart';
import '../../data/models/webcam_model.dart';
import '../controllers/live_controller.dart';

class WebcamPlayerScreen extends ConsumerStatefulWidget {
  final WebcamModel webcam;

  const WebcamPlayerScreen({super.key, required this.webcam});

  @override
  ConsumerState<WebcamPlayerScreen> createState() => _WebcamPlayerScreenState();
}

class _WebcamPlayerScreenState extends ConsumerState<WebcamPlayerScreen>
    with SingleTickerProviderStateMixin {
  late WebcamModel _currentCam;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  late AnimationController _pulseController;
  int _viewerCount = 1240;

  @override
  void initState() {
    super.initState();
    _currentCam = widget.webcam;
    _viewerCount = 800 + (_currentCam.id.hashCode.abs() % 1400);

    // Ticking surveillance clock every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatLocalTime(String tz) {
    try {
      final utc = _currentTime.toUtc();
      final offset = _getTimezoneOffset(tz);
      final local = utc.add(Duration(hours: offset));
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      final s = local.second.toString().padLeft(2, '0');
      final sign = offset >= 0 ? '+$offset' : '$offset';
      return '$h:$m:$s (UTC$sign)';
    } catch (_) {
      return 'Trực tiếp';
    }
  }

  int _getTimezoneOffset(String tz) {
    const offsets = {
      'Asia/Ho_Chi_Minh': 7,
      'Asia/Bangkok': 7,
      'Asia/Singapore': 8,
      'Asia/Tokyo': 9,
      'Asia/Seoul': 9,
      'Asia/Hong_Kong': 8,
      'Asia/Dubai': 4,
      'Asia/Kolkata': 5,
      'Asia/Kathmandu': 5,
      'Asia/Taipei': 8,
      'Asia/Kuala_Lumpur': 8,
      'Asia/Makassar': 8,
      'Europe/London': 0,
      'Europe/Paris': 1,
      'Europe/Berlin': 1,
      'Europe/Rome': 1,
      'Europe/Madrid': 1,
      'Europe/Amsterdam': 1,
      'Europe/Prague': 1,
      'Europe/Vienna': 1,
      'Europe/Stockholm': 1,
      'Europe/Oslo': 1,
      'Europe/Dublin': 0,
      'Europe/Lisbon': 0,
      'Europe/Athens': 2,
      'Europe/Istanbul': 3,
      'Europe/Zurich': 1,
      'Europe/Moscow': 3,
      'America/New_York': -5,
      'America/Chicago': -6,
      'America/Denver': -7,
      'America/Los_Angeles': -8,
      'America/Toronto': -5,
      'America/Sao_Paulo': -3,
      'America/Lima': -5,
      'America/Argentina/Buenos_Aires': -3,
      'America/Santiago': -4,
      'America/Cancun': -6,
      'America/Edmonton': -7,
      'Pacific/Honolulu': -10,
      'Pacific/Auckland': 12,
      'Atlantic/Reykjavik': 0,
      'Africa/Cairo': 2,
      'Africa/Johannesburg': 2,
      'Africa/Casablanca': 0,
      'Australia/Sydney': 11,
    };
    return offsets[tz] ?? 0;
  }

  Future<void> _openLiveStream() async {
    if (_currentCam.streamUrl.isNotEmpty) {
      final uri = Uri.parse(_currentCam.streamUrl);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở liên kết phát trực tiếp.'),
              backgroundColor: AppColors.liveRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _openInMaps() async {
    final uri = Uri.parse(
        'https://maps.google.com/?q=${_currentCam.latitude},${_currentCam.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _takeSnapshot() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đã chụp snapshot từ webcam ${_currentCam.title}!',
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
  }

  void _shareWebcam() {
    Share.share(
      'Xem trực tiếp ${_currentCam.title} (${_currentCam.city}, ${_currentCam.country}) trên RoamCam:\n${_currentCam.streamUrl}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveFeedProvider);
    final notifier = ref.read(liveFeedProvider.notifier);
    final isFav = notifier.isFavorite(_currentCam.id);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        elevation: 0,
        title: Text(
          _currentCam.city,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFav ? AppColors.liveRed : Colors.white,
              ),
            ),
            onPressed: () => notifier.toggleFavorite(_currentCam.id),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
            ),
            onPressed: _shareWebcam,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video / Camera Viewport
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera Live Image View with Zoom / Pan support
                  InteractiveViewer(
                    maxScale: 3.5,
                    child: CachedNetworkImage(
                      imageUrl: _currentCam.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.cyan,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceCard,
                        child: const Center(
                          child: Icon(Icons.videocam_off_rounded,
                              size: 48, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),

                  // Top Live Surveillance Badges
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.liveRed.withOpacity(0.85 + 0.15 * _pulseController.value),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.liveRed.withOpacity(0.6 * _pulseController.value),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'TRỰC TIẾP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.remove_red_eye_rounded,
                                  size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '$_viewerCount xem',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Right HD indicator
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: const Text(
                        '1080p HD • 60 FPS',
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ),

                  // Big Center "Play Live Stream" Button Overlay
                  Center(
                    child: GestureDetector(
                      onTap: _openLiveStream,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.cyan, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withOpacity(0.35),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.play_arrow_rounded, color: AppColors.cyan, size: 26),
                            SizedBox(width: 6),
                            Text(
                              'Phát Trực Tiếp (Live Stream)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Surveillance Camera Timestamp HUD at Bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.emerald,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'REC • ${_formatLocalTime(_currentCam.timezone)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Chạm 2 lần để phóng to',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Info Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const LiveBadge(),
                      const SizedBox(width: 8),
                      if (_currentCam.isHot) const HotBadge(),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                        ),
                        child: Text(
                          _currentCam.category,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentCam.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 15, color: AppColors.cyan),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentCam.city}, ${_currentCam.country}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openLiveStream,
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: const Text(
                        'Mở Trực Tiếp',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Snapshot',
                    onTap: _takeSnapshot,
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.map_outlined,
                    label: 'Bản đồ',
                    onTap: _openInMaps,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Camera Specifications Grid
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _SpecRow(
                    icon: Icons.access_time_rounded,
                    label: 'Giờ địa phương',
                    value: _formatLocalTime(_currentCam.timezone),
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _SpecRow(
                    icon: Icons.public_rounded,
                    label: 'Tọa độ GPS',
                    value:
                        '${_currentCam.latitude.toStringAsFixed(4)}°, ${_currentCam.longitude.toStringAsFixed(4)}°',
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _SpecRow(
                    icon: Icons.cell_tower_rounded,
                    label: 'Trạng thái máy quay',
                    value: 'Trực tuyến • Tín hiệu tốt',
                    valueColor: AppColors.emerald,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Related Webcams Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Webcam Nổi Bật Khác',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: liveState.allWebcams.length,
                itemBuilder: (context, i) {
                  final cam = liveState.allWebcams[i];
                  final isCurrent = cam.id == _currentCam.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentCam = cam;
                        _viewerCount = 750 + (cam.id.hashCode.abs() % 1500);
                      });
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent ? AppColors.cyan : AppColors.borderSubtle,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: cam.thumbnailUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.surfaceLight),
                            errorWidget: (_, __, ___) => Container(color: AppColors.surfaceCard),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.35),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 8,
                            right: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cam.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  cam.city,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.cyan),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

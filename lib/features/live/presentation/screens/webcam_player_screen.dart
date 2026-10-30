import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../core/widgets/hot_badge.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../data/models/webcam_model.dart';
import '../controllers/live_controller.dart';

class WebcamPlayerScreen extends ConsumerStatefulWidget {
  final WebcamModel webcam;

  const WebcamPlayerScreen({super.key, required this.webcam});

  @override
  ConsumerState<WebcamPlayerScreen> createState() => _WebcamPlayerScreenState();
}

class _WebcamPlayerScreenState extends ConsumerState<WebcamPlayerScreen> {
  bool _streamError = false;

  String get _localTimeText {
    try {
      final now = DateTime.now().toUtc();
      final offsetHours = _getTimezoneOffset(widget.webcam.timezone);
      final localTime = now.add(Duration(hours: offsetHours));
      final h = localTime.hour.toString().padLeft(2, '0');
      final m = localTime.minute.toString().padLeft(2, '0');
      return '$h:$m (Local)';
    } catch (_) {
      return 'Local Time';
    }
  }

  int _getTimezoneOffset(String tz) {
    const offsets = {
      'Asia/Ho_Chi_Minh': 7, 'Asia/Bangkok': 7, 'Asia/Singapore': 8,
      'Asia/Tokyo': 9, 'Asia/Seoul': 9, 'Asia/Hong_Kong': 8,
      'Asia/Dubai': 4, 'Asia/Kolkata': 5, 'Asia/Kathmandu': 5,
      'Asia/Taipei': 8, 'Asia/Kuala_Lumpur': 8, 'Asia/Makassar': 8,
      'Europe/London': 0, 'Europe/Paris': 1, 'Europe/Berlin': 1,
      'Europe/Rome': 1, 'Europe/Madrid': 1, 'Europe/Amsterdam': 1,
      'Europe/Prague': 1, 'Europe/Vienna': 1, 'Europe/Stockholm': 1,
      'Europe/Oslo': 1, 'Europe/Dublin': 0, 'Europe/Lisbon': 0,
      'Europe/Athens': 2, 'Europe/Istanbul': 3, 'Europe/Zurich': 1,
      'Europe/Moscow': 3,
      'America/New_York': -5, 'America/Chicago': -6, 'America/Denver': -7,
      'America/Los_Angeles': -8, 'America/Toronto': -5,
      'America/Sao_Paulo': -3, 'America/Lima': -5,
      'America/Argentina/Buenos_Aires': -3, 'America/Santiago': -4,
      'America/Cancun': -6,
      'America/Edmonton': -7,
      'Pacific/Honolulu': -10, 'Pacific/Auckland': 12,
      'Atlantic/Reykjavik': 0,
      'Africa/Cairo': 2, 'Africa/Johannesburg': 2, 'Africa/Casablanca': 0,
      'Australia/Sydney': 11,
    };
    return offsets[tz] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveFeedProvider);
    final notifier = ref.read(liveFeedProvider.notifier);
    final isFav = notifier.isFavorite(widget.webcam.id);

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
              color: Colors.black.withOpacity(0.45),
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
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFav ? AppColors.liveRed : Colors.white,
              ),
            ),
            onPressed: () => notifier.toggleFavorite(widget.webcam.id),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.open_in_browser, size: 18, color: Colors.white),
            ),
            onPressed: () async {
              if (widget.webcam.streamUrl.isNotEmpty) {
                await launchUrl(Uri.parse(widget.webcam.streamUrl),
                    mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Thumbnail as background when no stream
          if (_streamError || widget.webcam.streamUrl.isEmpty)
            Positioned.fill(
              child: Image.network(
                widget.webcam.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.background,
                  child: const Center(
                    child: Icon(Icons.videocam_off_rounded,
                        size: 60, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),

          if (_streamError)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: ErrorRetryView(
                  title: 'Stream Unavailable',
                  message: 'The live feed cannot be reached. Open in browser to try.',
                  onRetry: () => setState(() => _streamError = false),
                ),
              ),
            ),

          // Bottom info card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
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
                      const LiveBadge(),
                      const SizedBox(width: 8),
                      if (widget.webcam.isHot) const HotBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.webcam.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.cyan),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.webcam.city}, ${widget.webcam.country}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 13, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        _localTimeText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
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


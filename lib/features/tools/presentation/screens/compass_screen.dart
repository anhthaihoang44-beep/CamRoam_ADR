import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/coord_formatter.dart';

final _compassProvider = StreamProvider.autoDispose<double>((ref) {
  // Low Pass Filter alpha
  const alpha = 0.12;
  double filtered = 0;

  return magnetometerEventStream().map((event) {
    // Calculate azimuth from magnetometer X/Y
    double raw = math.atan2(event.y, event.x) * (180 / math.pi);
    if (raw < 0) raw += 360;
    // LPF: filtered = alpha * raw + (1-alpha) * filtered
    filtered = alpha * raw + (1 - alpha) * filtered;
    return filtered;
  });
});

class CompassScreen extends ConsumerStatefulWidget {
  const CompassScreen({super.key});

  @override
  ConsumerState<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends ConsumerState<CompassScreen> {
  String _coords = 'Acquiring GPS...';

  @override
  void initState() {
    super.initState();
    _fetchCoords();
  }

  Future<void> _fetchCoords() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        setState(() {
          _coords = CoordFormatter.format(pos.latitude, pos.longitude);
        });
      } else {
        setState(() => _coords = 'Location unavailable');
      }
    } catch (_) {
      setState(() => _coords = 'Location unavailable');
    }
  }

  @override
  Widget build(BuildContext context) {
    final compassAsync = ref.watch(_compassProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Digital Compass'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: compassAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.cyan),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_rounded, size: 60, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text(
                'Compass sensor not available',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'This device may not have a magnetometer.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        data: (heading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Compass Dial
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: _CompassPainter(heading: heading),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CoordFormatter.formatHeading(heading),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Magnetic North',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Coordinates
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.cyan, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _coords,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Calibration tip
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.hotOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.hotOrange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.hotOrange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For best accuracy: rotate your phone in a figure-8 pattern to calibrate.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  const _CompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 8;

    // Outer ring
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.borderSubtle
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), radius, outerPaint);

    // Inner glow ring
    final innerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.cyan.withOpacity(0.35)
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx, cy), radius - 18, innerGlow);

    // Degree ticks
    for (int i = 0; i < 360; i += 5) {
      final isCardinal = i % 90 == 0;
      final isMajor = i % 45 == 0;
      final tickLen = isCardinal ? 18.0 : isMajor ? 12.0 : 6.0;
      final tickWidth = isCardinal ? 2.5 : 1.2;
      final angle = (i - heading) * math.pi / 180;
      final start = Offset(
        cx + (radius - 4) * math.sin(angle),
        cy - (radius - 4) * math.cos(angle),
      );
      final end = Offset(
        cx + (radius - 4 - tickLen) * math.sin(angle),
        cy - (radius - 4 - tickLen) * math.cos(angle),
      );
      final tickPaint = Paint()
        ..color = isCardinal ? AppColors.cyan : AppColors.textMuted.withOpacity(0.6)
        ..strokeWidth = tickWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, end, tickPaint);
    }

    // Cardinal labels
    final labelStyle = TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold);
    final northStyle = TextStyle(color: AppColors.emerald, fontSize: 16, fontWeight: FontWeight.w900);

    for (final entry in {'N': 0, 'E': 90, 'S': 180, 'W': 270}.entries) {
      final angle = (entry.value - heading) * math.pi / 180;
      final labelR = radius - 36.0;
      final offset = Offset(
        cx + labelR * math.sin(angle),
        cy - labelR * math.cos(angle),
      );
      final style = entry.key == 'N' ? northStyle : labelStyle;
      final tp = TextPainter(
        text: TextSpan(text: entry.key, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(offset.dx - tp.width / 2, offset.dy - tp.height / 2));
    }

    // Needle (pointing to North, i.e. heading=0 → up)
    final needlePaint = Paint()
      ..color = AppColors.emerald
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final needleLen = radius - 50;
    const needleAngle = 0.0; // Always points to North in rotated frame
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + needleLen * math.sin(needleAngle), cy - needleLen * math.cos(needleAngle)),
      needlePaint,
    );

    // South needle (opposite, red)
    final southPaint = Paint()
      ..color = AppColors.liveRed
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + (needleLen * 0.6) * math.sin(needleAngle + math.pi),
          cy - (needleLen * 0.6) * math.cos(needleAngle + math.pi)),
      southPaint,
    );

    // Center dot
    canvas.drawCircle(
      Offset(cx, cy),
      8,
      Paint()..color = AppColors.surfaceCard,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      5,
      Paint()..color = AppColors.emerald,
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.heading != heading;
}


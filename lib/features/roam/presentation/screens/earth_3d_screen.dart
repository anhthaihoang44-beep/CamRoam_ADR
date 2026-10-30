import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class Earth3dScreen extends StatefulWidget {
  const Earth3dScreen({super.key});

  @override
  State<Earth3dScreen> createState() => _Earth3dScreenState();
}

class _Earth3dScreenState extends State<Earth3dScreen> with TickerProviderStateMixin {
  late AnimationController _rotController;
  late AnimationController _glowController;
  double _angle = 0;

  final List<({String name, double lat, double lng, String emoji, String country})> _cities = [
    (name: 'Tokyo', lat: 35.6, lng: 139.7, emoji: '🗼', country: 'Japan'),
    (name: 'New York', lat: 40.7, lng: -74.0, emoji: '🗽', country: 'United States'),
    (name: 'Paris', lat: 48.8, lng: 2.3, emoji: '🗼', country: 'France'),
    (name: 'Sydney', lat: -33.9, lng: 151.2, emoji: '🦘', country: 'Australia'),
    (name: 'Da Nang', lat: 16.0, lng: 108.2, emoji: '🐉', country: 'Vietnam'),
    (name: 'Dubai', lat: 25.2, lng: 55.3, emoji: '🏙️', country: 'UAE'),
    (name: 'London', lat: 51.5, lng: -0.1, emoji: '👑', country: 'United Kingdom'),
    (name: 'Rio', lat: -22.9, lng: -43.2, emoji: '🏖️', country: 'Brazil'),
  ];

  @override
  void initState() {
    super.initState();
    _rotController = AnimationController(vsync: this, duration: const Duration(seconds: 32))..repeat();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _showCitySheet(({String name, double lat, double lng, String emoji, String country}) city) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(city.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${city.country} • ${city.lat}° N, ${city.lng}° E',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/map-webcams');
                      },
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: const Text('Xem Webcams'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final uri = Uri.parse('https://maps.google.com/?q=${city.lat},${city.lng}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('Mở Google Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040810),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('3D Earth', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chạm vào thành phố để khám phá',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Interactive spinning globe
            GestureDetector(
              onPanUpdate: (d) => setState(() => _angle += d.delta.dx * 0.01),
              child: AnimatedBuilder(
                animation: _rotController,
                builder: (ctx, _) {
                  final autoAngle = _rotController.value * 2 * math.pi;
                  return SizedBox(
                    width: 280,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _GlobePainter(
                            autoAngle: autoAngle,
                            manualAngle: _angle,
                            glowPulse: _glowController.value,
                            cities: _cities,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // City tiles
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _cities.length,
                itemBuilder: (context, i) {
                  final city = _cities[i];
                  return GestureDetector(
                    onTap: () {
                      final targetAngle = city.lng * math.pi / 180;
                      setState(() => _angle = targetAngle);
                      _showCitySheet(city);
                    },
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(city.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            city.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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
    );
  }
}

class _GlobePainter extends CustomPainter {
  final double autoAngle;
  final double manualAngle;
  final double glowPulse;
  final List<({String name, double lat, double lng, String emoji, String country})> cities;

  _GlobePainter({
    required this.autoAngle,
    required this.manualAngle,
    required this.glowPulse,
    required this.cities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 10;

    // Background glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.cyan.withOpacity(0.15 + 0.05 * glowPulse),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius + 20));
    canvas.drawCircle(Offset(cx, cy), radius + 20, glowPaint);

    // Globe base
    final globePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFF1A4B6E), Color(0xFF0A2740), Color(0xFF050E1A)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, globePaint);

    // Latitude lines
    final latPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.cyan.withOpacity(0.12)
      ..strokeWidth = 0.8;
    for (int lat = -60; lat <= 60; lat += 30) {
      final y = cy + radius * math.sin(lat * math.pi / 180);
      final r2 = radius * math.cos(lat * math.pi / 180);
      if (r2 > 0) {
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, y), width: r2 * 2, height: r2 * 0.35), latPaint);
      }
    }

    // Longitude lines
    final totalAngle = autoAngle + manualAngle;
    for (int lng = 0; lng < 360; lng += 30) {
      final angle = (lng * math.pi / 180) + totalAngle;
      final xA = cx + radius * math.sin(angle);
      final xB = cx - radius * math.sin(angle);
      canvas.drawLine(Offset(xA, cy - radius), Offset(xB, cy + radius), latPaint);
    }

    // City markers
    for (final city in cities) {
      final lngRad = (city.lng * math.pi / 180) + totalAngle;
      final latRad = city.lat * math.pi / 180;
      final x = cx + radius * math.cos(latRad) * math.sin(lngRad);
      final y = cy - radius * math.sin(latRad);
      final z = math.cos(latRad) * math.cos(lngRad);

      if (z > 0.1) {
        final dotPaint = Paint()..color = AppColors.cyan.withOpacity(0.8 * z);
        canvas.drawCircle(Offset(x, y), 4, dotPaint);

        final tp = TextPainter(
          text: TextSpan(
            text: city.emoji,
            style: TextStyle(fontSize: 14 * z.clamp(0.5, 1.0)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y - 18));
      }
    }

    // Atmosphere ring
    final atmPaint = Paint()
      ..style = PaintingStyle.stroke
      ..shader = SweepGradient(
        colors: [
          AppColors.cyan.withOpacity(0.3),
          Colors.transparent,
          AppColors.cyan.withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
      ..strokeWidth = 8;
    canvas.drawCircle(Offset(cx, cy), radius, atmPaint);
  }

  @override
  bool shouldRepaint(_GlobePainter old) =>
      old.autoAngle != autoAngle || old.manualAngle != manualAngle || old.glowPulse != glowPulse;
}

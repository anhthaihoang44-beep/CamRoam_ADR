import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LiveBadge extends StatefulWidget {
  final double fontSize;
  final bool compact;

  const LiveBadge({
    super.key,
    this.fontSize = 11,
    this.compact = false,
  });

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 6 : 8,
            vertical: widget.compact ? 2 : 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.liveRed.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.liveRed.withOpacity(0.5 * _pulseAnimation.value),
                blurRadius: 8 * _pulseAnimation.value,
                spreadRadius: 1 * _pulseAnimation.value,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(_pulseAnimation.value),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: widget.fontSize,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


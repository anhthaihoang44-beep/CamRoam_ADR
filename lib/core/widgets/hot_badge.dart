import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HotBadge extends StatelessWidget {
  final double fontSize;

  const HotBadge({
    super.key,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppColors.hotBadgeGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.hotOrange.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            'HOT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


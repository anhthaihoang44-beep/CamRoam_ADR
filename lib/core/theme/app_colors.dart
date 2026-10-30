import 'package:flutter/material.dart';

/// RoamCam Dark Space & Cyber Navy Design System Colors
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF080D1A);
  static const Color surface = Color(0xFF10192B);
  static const Color surfaceCard = Color(0xFF162238);
  static const Color surfaceLight = Color(0xFF1E2E4A);

  // Accents
  static const Color cyan = Color(0xFF00E5FF);
  static const Color emerald = Color(0xFF00F5D4);
  static const Color neonBlue = Color(0xFF2979FF);

  // Status & Badges
  static const Color liveRed = Color(0xFFFF1744);
  static const Color liveRedGlow = Color(0x66FF1744);
  static const Color hotOrange = Color(0xFFFF6D00);
  static const Color purpleGlow = Color(0xFF7C4DFF);

  // Text
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF586069);

  // Borders & Dividers
  static const Color borderSubtle = Color(0x1FFFFFFF);
  static const Color borderGlow = Color(0x4D00E5FF);

  // Overlay gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hotBadgeGradient = LinearGradient(
    colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}


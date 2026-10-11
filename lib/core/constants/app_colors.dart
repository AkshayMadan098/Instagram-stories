import 'package:flutter/material.dart';

class AppColors {
  // Instagram Brand Colors
  static const Color instagramPurple = Color(0xFF833AB4);
  static const Color instagramPink = Color(0xFFE1306C);
  static const Color instagramOrange = Color(0xFFF77737);
  static const Color instagramYellow = Color(0xFFFCAF45);
  static const Color instagramBlue = Color(0xFF405DE6);

  static const LinearGradient instagramGradient = LinearGradient(
    colors: [
      Color(0xFF833AB4),
      Color(0xFFFD1D1D),
      Color(0xFFFCB045),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient instagramStoryRing = LinearGradient(
    colors: [
      Color(0xFF9B2282),
      Color(0xFFEE2A7B),
      Color(0xFFFF7A00),
      Color(0xFFFFC107),
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // Canvas / Editor Colors
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color overlayDark = Color(0x99000000);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color accent = Color(0xFF3897F0);
  static const Color danger = Color(0xFFED4956);
  static const Color success = Color(0xFF00C853);

  // Drawing Palette Colors (Instagram Story Style)
  static const List<Color> paletteColors = [
    Colors.white,
    Colors.black,
    Color(0xFFFF2A6D), // Hot Pink
    Color(0xFFFF0055), // Crimson
    Color(0xFFFF6F00), // Vibrant Orange
    Color(0xFFFFD600), // Sunshine Yellow
    Color(0xFF00E676), // Bright Green
    Color(0xFF00E5FF), // Cyan
    Color(0xFF2979FF), // Electric Blue
    Color(0xFFD500F9), // Purple Neon
    Color(0xFF8E24AA), // Deep Violet
    Color(0xFF795548), // Brown
  ];
}

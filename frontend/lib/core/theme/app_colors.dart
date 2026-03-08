import 'package:flutter/material.dart';

/// Questly color palette — true OLED black canvas with olive/cream tones.
///
/// Neon bloom effects should remain minimal — used on small interactive
/// elements (badges, active indicators, FABs) only.
class AppColors {
  AppColors._();

  // ── Brand (Dark Mode – OLED) ──────────────────────────────
  static const Color brand = Color(0xFFD9D6A0); // vivid olive – pops on black
  static const Color muted = Color(0xFF585749); // olive-gray – visible on black
  static const Color surface = Color(0xFF000000); // true black – OLED
  static const Color fore = Color(0xFFEEEDD8); // bright cream – high contrast

  // ── Background & Surface ──────────────────────────────────
  static const Color background = Color(0xFF000000);
  static const Color surfaceLight = Color(0xFF111110);
  static const Color card = Color(0xFF0A0A09);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = fore;
  static const Color textSecondary = Color(0xFFB5B4A2);
  static const Color textHint = muted;
  static const Color textDisabled = Color(0xFF3D3C35);

  // ── Borders ───────────────────────────────────────────────
  static const Color border = Color(0xFF2A2924);
  static const Color borderLight = Color(0xFF1E1D1A);
  static const Color divider = Color(0xFF1A1917);

  // ── Neon Accents (bloom – small components only) ──────────
  static const Color neonOlive = Color(0xFFD9D6A0);
  static const Color neonOliveLight = Color(0xFFE8E6C0);
  static const Color neonOliveDim = Color(0x33D9D6A0);

  static const Color neonCream = Color(0xFFEEEDD8);
  static const Color neonCreamDim = Color(0x33EEEDD8);

  static const Color neonAmber = Color(0xFFE8C547);
  static const Color neonAmberDim = Color(0x33E8C547);

  // ── Functional (mapped) ───────────────────────────────────
  static const Color primary = brand;
  static const Color primaryLight = neonOliveLight;
  static const Color primaryDim = neonOliveDim;

  static const Color secondary = muted;
  static const Color secondaryDim = Color(0x33585749);

  static const Color accent = neonAmber; // use sparingly — bloom
  static const Color accentDim = neonAmberDim;

  static const Color success = Color(0xFF7AC74F);
  static const Color successDim = Color(0x337AC74F);

  static const Color info = brand;
  static const Color infoDim = neonOliveDim;

  static const Color error = Color(0xFFCC4444);
  static const Color errorDim = Color(0x33CC4444);

  static const Color warning = neonAmber;
  static const Color warningDim = neonAmberDim;

  // ── Chips / Tags ──────────────────────────────────────────
  static const Color chipBackground = Color(0xFF151513);
  static const Color chipSelected = neonOliveDim;
  static const Color chipBorder = Color(0xFF2A2924);

  // ── Navigation ────────────────────────────────────────────
  static const Color navBackground = Color(0xFF0A0A09);
  static const Color navSelected = brand;
  static const Color navUnselected = muted;

  // ── Shimmer / Skeleton ────────────────────────────────────
  static const Color shimmerBase = Color(0xFF151513);
  static const Color shimmerHighlight = Color(0xFF2A2924);

  // ── Legacy aliases (backward compat — maps old neon names to new palette) ──
  static const Color neonCyan = brand; // was 0xFF00D4FF → now olive brand
  static const Color neonCyanLight = neonOliveLight;
  static const Color neonCyanDim = neonOliveDim;
  static const Color neonGreen = Color(0xFF7AC74F); // muted green for success
  static const Color neonGreenLight = Color(0xFF9FD87A);
  static const Color neonGreenDim = Color(0x337AC74F);
  static const Color neonOrange =
      neonAmber; // warm amber instead of harsh orange
  static const Color neonOrangeLight = Color(0xFFEED36B);
  static const Color neonOrangeDim = neonAmberDim;
}

import 'package:flutter/material.dart';

/// Questly color palette — pitch black canvas, white type, neon accents.
///
/// Hierarchy: **cyan** (primary) → **green** (secondary / success)
///            → orange (rare spark accent only).
class AppColors {
  AppColors._();

  // ── Background & Surface ──────────────────────────────────
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceLight = Color(0xFF141414);
  static const Color card = Color(0xFF1A1A1A);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF444444);

  // ── Borders ───────────────────────────────────────────────
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFF1E1E1E);
  static const Color divider = Color(0xFF1A1A1A);

  // ── Neon Accents ──────────────────────────────────────────
  static const Color neonCyan = Color(0xFF00D4FF);
  static const Color neonCyanLight = Color(0xFF33DDFF);
  static const Color neonCyanDim = Color(0x3300D4FF);

  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonGreenLight = Color(0xFF66FF44);
  static const Color neonGreenDim = Color(0x3339FF14);

  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonOrangeLight = Color(0xFFFF8C33);
  static const Color neonOrangeDim = Color(0x33FF6B00);

  // ── Functional (mapped) ───────────────────────────────────
  static const Color primary = neonCyan;
  static const Color primaryLight = neonCyanLight;
  static const Color primaryDim = neonCyanDim;

  static const Color secondary = neonGreen;
  static const Color secondaryDim = neonGreenDim;

  static const Color accent = neonOrange; // use sparingly
  static const Color accentDim = neonOrangeDim;

  static const Color success = neonGreen;
  static const Color successDim = neonGreenDim;

  static const Color info = neonCyan;
  static const Color infoDim = neonCyanDim;

  static const Color error = Color(0xFFFF3B3B);
  static const Color errorDim = Color(0x33FF3B3B);

  static const Color warning = Color(0xFFFFD600);
  static const Color warningDim = Color(0x33FFD600);

  // ── Chips / Tags ──────────────────────────────────────────
  static const Color chipBackground = Color(0xFF1E1E1E);
  static const Color chipSelected = neonCyanDim;
  static const Color chipBorder = Color(0xFF333333);

  // ── Navigation ────────────────────────────────────────────
  static const Color navBackground = Color(0xFF0A0A0A);
  static const Color navSelected = neonCyan;
  static const Color navUnselected = Color(0xFF666666);

  // ── Shimmer / Skeleton ────────────────────────────────────
  static const Color shimmerBase = Color(0xFF1A1A1A);
  static const Color shimmerHighlight = Color(0xFF2A2A2A);
}

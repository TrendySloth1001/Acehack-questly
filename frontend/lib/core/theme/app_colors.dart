import 'package:flutter/material.dart';

/// Questly colour palette — warm cream canvas with olive accents.
///
/// Derived from the four-role system:
///   brand   #545333  olive – primary actions
///   muted   #878672  grey-olive – structure
///   surface #FDFBD4  warm cream – canvas
///   fore    #2E2D1E  deep olive – text
///
/// NO glow, NO bloom — just these colours.
class AppColors {
  AppColors._();

  // ── Four-role tokens (Light) ──────────────────────────────
  static const Color brand = Color(0xFF545333);
  static const Color muted = Color(0xFF878672);
  static const Color surface = Color(0xFFFDFBD4);
  static const Color fore = Color(0xFF2E2D1E);

  // ── Background & Surface ──────────────────────────────────
  static const Color background = surface;
  static const Color surfaceLight = Color(0xFFF5F3C8);
  static const Color card = Color(0xFFFAF8D0);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = fore;
  static const Color textSecondary = muted;
  static const Color textHint = Color(0xFFA5A494);
  static const Color textDisabled = Color(0xFFC5C4B6);

  // ── Borders ───────────────────────────────────────────────
  static const Color border = Color(0xFFD0CEAE);
  static const Color borderLight = Color(0xFFE0DEC4);
  static const Color divider = Color(0xFFE5E3C8);

  // ── Functional (mapped) ───────────────────────────────────
  static const Color primary = brand;
  static const Color primaryLight = Color(0xFF6E6B49);
  static const Color primaryDim = Color(0x33545333);

  static const Color secondary = muted;
  static const Color secondaryDim = Color(0x33878672);

  static const Color accent = Color(0xFF8C7A3A);
  static const Color accentDim = Color(0x338C7A3A);

  static const Color success = Color(0xFF4A7A2E);
  static const Color successDim = Color(0x334A7A2E);

  static const Color info = brand;
  static const Color infoDim = primaryDim;

  static const Color error = Color(0xFF9B3030);
  static const Color errorDim = Color(0x339B3030);

  static const Color warning = Color(0xFF8C7A3A);
  static const Color warningDim = Color(0x338C7A3A);

  // ── Chips / Tags ──────────────────────────────────────────
  static const Color chipBackground = Color(0xFFF0EEC4);
  static const Color chipSelected = primaryDim;
  static const Color chipBorder = Color(0xFFD0CEAE);

  // ── Navigation ────────────────────────────────────────────
  static const Color navBackground = surface;
  static const Color navSelected = brand;
  static const Color navUnselected = muted;

  // ── Shimmer / Skeleton ────────────────────────────────────
  static const Color shimmerBase = Color(0xFFF0EEC4);
  static const Color shimmerHighlight = Color(0xFFE5E3C8);

  // ── Legacy aliases (keep screens compiling) ───────────────
  static const Color neonCyan = brand;
  static const Color neonCyanLight = primaryLight;
  static const Color neonCyanDim = primaryDim;
  static const Color neonGreen = success;
  static const Color neonGreenLight = Color(0xFF6A9A4E);
  static const Color neonGreenDim = successDim;
  static const Color neonOrange = warning;
  static const Color neonOrangeLight = Color(0xFFA8944E);
  static const Color neonOrangeDim = warningDim;
  static const Color neonOlive = brand;
  static const Color neonOliveLight = primaryLight;
  static const Color neonOliveDim = primaryDim;
  static const Color neonCream = fore;
  static const Color neonCreamDim = Color(0x332E2D1E);
  static const Color neonAmber = warning;
  static const Color neonAmberDim = warningDim;
}

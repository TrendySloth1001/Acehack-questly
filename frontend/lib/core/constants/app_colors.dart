import 'package:flutter/material.dart';

/// Strictly minimal four-role colour system for Tutorix.
///
/// Each mode defines exactly four tokens:
///   1. **brand**   – dominant anchor for primary actions and emphasis
///   2. **muted**   – secondary supportive tone for structure and de-emphasis
///   3. **surface** – neutral canvas / background
///   4. **fore**    – readable foreground for text and content
///
/// Screens must use `Theme.of(context).colorScheme` or
/// `Theme.of(context).scaffoldBackgroundColor` – never reference these
/// constants directly except inside [AppTheme].
class AppColors {
  AppColors._();

  // ── Light Mode ─────────────────────────────────────────────────────────
  static const Color brand = Color(0xFF545333); // olive – primary actions
  static const Color muted = Color(0xFF878672); // grey-olive – structure
  static const Color surface = Color(0xFFFDFBD4); // warm cream – canvas
  static const Color fore = Color(0xFF2E2D1E); // deep olive – text

  // ── Dark Mode (OLED) ───────────────────────────────────────────────
  static const Color brandD = Color(0xFFD9D6A0); // vivid olive – pops on black
  static const Color mutedD = Color(
    0xFF585749,
  ); // olive-gray – visible on black
  static const Color surfaceD = Color(0xFF000000); // true black – OLED
  static const Color foreD = Color(
    0xFFEEEDD8,
  ); // bright cream – high OLED contrast
}

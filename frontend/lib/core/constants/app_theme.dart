import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'design_tokens.dart';

/// Application-wide Material 3 theme built from the four-role [AppColors].
///
/// ColorScheme mapping (both modes):
///   primary       → brand   (actions, emphasis)
///   onPrimary     → surface (text on brand fills)
///   secondary     → muted   (structure, de-emphasis)
///   onSecondary   → surface
///   surface       → surface (backgrounds)
///   onSurface     → fore    (primary text)
///   onSurfaceVariant → muted (secondary text)
///   outline       → muted
///   outlineVariant → muted at 30 %
///   error         → fore    (no separate hue – use weight / icons)
///   onError       → surface
class AppTheme {
  AppTheme._();

  // ── Light ──────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.brand,
      onPrimary: AppColors.surface,
      secondary: AppColors.muted,
      onSecondary: AppColors.surface,
      tertiary: AppColors.muted,
      onTertiary: AppColors.fore,
      surface: AppColors.surface,
      onSurface: AppColors.fore,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.muted,
      outlineVariant: AppColors.muted.withValues(alpha: 0.3),
      surfaceContainerHighest: const Color(0xFFF0EEC4),
      error: AppColors.fore,
      onError: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,

      // Card
      cardTheme: CardThemeData(
        color: AppColors.muted.withValues(alpha: 0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: AppColors.muted.withValues(alpha: 0.2)),
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sp24,
            vertical: Spacing.sp16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          side: const BorderSide(color: AppColors.brand, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sp24,
            vertical: Spacing.sp16,
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.muted.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: AppColors.muted.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: AppColors.muted.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.brand),
      ),

      // Text — 7-role ramp mapped to 15 Material slots
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: FontSize.hero,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -1.0,
          color: AppColors.fore,
        ),
        displayMedium: TextStyle(
          fontSize: FontSize.hero,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.5,
          color: AppColors.fore,
        ),
        displaySmall: TextStyle(
          fontSize: FontSize.hero,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: AppColors.fore,
        ),
        headlineLarge: TextStyle(
          fontSize: FontSize.title,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.fore,
        ),
        headlineMedium: TextStyle(
          fontSize: FontSize.title,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.fore,
        ),
        headlineSmall: TextStyle(
          fontSize: FontSize.title,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: AppColors.fore,
        ),
        titleLarge: TextStyle(
          fontSize: FontSize.sub,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.fore,
        ),
        titleMedium: TextStyle(
          fontSize: FontSize.sub,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.fore,
        ),
        titleSmall: TextStyle(
          fontSize: FontSize.body,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.fore,
        ),
        bodyLarge: TextStyle(
          fontSize: FontSize.body,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.fore,
        ),
        bodyMedium: TextStyle(
          fontSize: FontSize.body,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.fore,
        ),
        bodySmall: TextStyle(
          fontSize: FontSize.caption,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.fore,
        ),
        labelLarge: TextStyle(
          fontSize: FontSize.body,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.fore,
        ),
        labelMedium: TextStyle(
          fontSize: FontSize.caption,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.fore,
        ),
        labelSmall: TextStyle(
          fontSize: FontSize.micro,
          fontWeight: FontWeight.w500,
          height: 1.4,
          letterSpacing: 0.5,
          color: AppColors.fore,
        ),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.fore,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Bottom nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.brand,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // ── Dark ───────────────────────────────────────────────────────────────

  static const _scaffold = Color(0xFF000000); // true black for OLED

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.brandD,
      onPrimary: AppColors.surfaceD,
      secondary: AppColors.mutedD,
      onSecondary: AppColors.foreD,
      tertiary: AppColors.mutedD,
      onTertiary: AppColors.foreD,
      surface: AppColors.surfaceD,
      onSurface: AppColors.foreD,
      onSurfaceVariant: AppColors.mutedD,
      outline: AppColors.mutedD,
      outlineVariant: AppColors.mutedD.withValues(alpha: 0.3),
      surfaceContainerHighest: const Color(0xFF111110),
      error: AppColors.foreD,
      onError: AppColors.surfaceD,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'SF Pro',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _scaffold,

      // Card
      cardTheme: CardThemeData(
        color: const Color(0xFF0A0A09),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: AppColors.mutedD.withValues(alpha: 0.15)),
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandD,
          foregroundColor: AppColors.surfaceD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sp24,
            vertical: Spacing.sp16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreD,
          side: BorderSide(color: AppColors.foreD.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sp24,
            vertical: Spacing.sp16,
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.mutedD.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(
            color: AppColors.mutedD.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(
            color: AppColors.mutedD.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: AppColors.brandD, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.foreD),
      ),

      // Text — 7-role ramp mapped to 15 Material slots
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: FontSize.hero,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -1.0,
          color: AppColors.foreD,
        ),
        displayMedium: TextStyle(
          fontSize: FontSize.hero,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.5,
          color: AppColors.foreD,
        ),
        displaySmall: TextStyle(
          fontSize: FontSize.hero,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: AppColors.foreD,
        ),
        headlineLarge: TextStyle(
          fontSize: FontSize.title,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.foreD,
        ),
        headlineMedium: TextStyle(
          fontSize: FontSize.title,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.foreD,
        ),
        headlineSmall: TextStyle(
          fontSize: FontSize.title,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: AppColors.foreD,
        ),
        titleLarge: TextStyle(
          fontSize: FontSize.sub,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.foreD,
        ),
        titleMedium: TextStyle(
          fontSize: FontSize.sub,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.foreD,
        ),
        titleSmall: TextStyle(
          fontSize: FontSize.body,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.foreD,
        ),
        bodyLarge: TextStyle(
          fontSize: FontSize.body,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.foreD,
        ),
        bodyMedium: TextStyle(
          fontSize: FontSize.body,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.foreD,
        ),
        bodySmall: TextStyle(
          fontSize: FontSize.caption,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.foreD,
        ),
        labelLarge: TextStyle(
          fontSize: FontSize.body,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.foreD,
        ),
        labelMedium: TextStyle(
          fontSize: FontSize.caption,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.foreD,
        ),
        labelSmall: TextStyle(
          fontSize: FontSize.micro,
          fontWeight: FontWeight.w500,
          height: 1.4,
          letterSpacing: 0.5,
          color: AppColors.foreD,
        ),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: _scaffold,
        foregroundColor: AppColors.foreD,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Bottom nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF000000),
        selectedItemColor: AppColors.brandD,
        unselectedItemColor: AppColors.mutedD,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0A0A09),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: AppColors.mutedD.withValues(alpha: 0.15)),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF0A0A09),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),

      // Popup Menu
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF0A0A09),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: AppColors.mutedD.withValues(alpha: 0.15)),
        ),
      ),

      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF000000),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

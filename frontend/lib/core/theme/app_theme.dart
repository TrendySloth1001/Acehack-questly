import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Light theme — warm cream canvas, olive accents, no glow.
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surface,
    fontFamily: 'SF Pro',
    colorScheme: ColorScheme.light(
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
      surfaceContainerHighest: AppColors.chipBackground,
      error: AppColors.error,
      onError: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.fore,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: AppColors.fore,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'SF Pro',
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.muted.withValues(alpha: 0.2)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.surface,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'SF Pro',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.fore,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: AppColors.fore.withValues(alpha: 0.3)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.brand),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.muted.withValues(alpha: 0.06),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.muted.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.muted.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.chipBackground,
      selectedColor: AppColors.chipSelected,
      side: BorderSide(color: AppColors.chipBorder, width: 0.5),
      labelStyle: const TextStyle(color: AppColors.fore, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navBackground,
      indicatorColor: AppColors.primaryDim,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.navSelected, size: 22);
        }
        return const IconThemeData(color: AppColors.navUnselected, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.navSelected,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(color: AppColors.navUnselected, fontSize: 11);
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.card,
      contentTextStyle: const TextStyle(color: AppColors.fore, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.muted.withValues(alpha: 0.15)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.muted.withValues(alpha: 0.15)),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.brand,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w800,
        fontSize: 32,
        height: 1.1,
        letterSpacing: -1.0,
      ),
      displayMedium: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w800,
        fontSize: 28,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        height: 1.15,
      ),
      headlineLarge: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w800,
        fontSize: 28,
      ),
      headlineMedium: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      headlineSmall: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      titleSmall: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.3,
      ),
      bodyLarge: TextStyle(color: AppColors.fore, fontSize: 14, height: 1.5),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: AppColors.textHint,
        fontSize: 11,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        color: AppColors.fore,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      labelMedium: TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        color: AppColors.textHint,
        fontWeight: FontWeight.w500,
        fontSize: 10,
        height: 1.4,
        letterSpacing: 0.5,
      ),
    ),
  );
}

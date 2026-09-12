import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens — the single source of truth (doc 04 §2).
/// Dark theme only. No hardcoded colours anywhere else in the app.
abstract final class AppColors {
  static const bg = Color(0xFF0E1013);
  static const surface = Color(0xFF171A1F);
  static const surfaceAlt = Color(0xFF1F242B);
  static const border = Color(0xFF2A3039);
  static const primary = Color(0xFFFF6B2C);
  static const primaryDim = Color(0xFF8A3A18);
  static const success = Color(0xFF34C77B);
  static const warning = Color(0xFFF5A524);
  static const danger = Color(0xFFE5484D);
  static const info = Color(0xFF4C8DFF);
  static const textPrimary = Color(0xFFF2F4F7);
  static const textSecondary = Color(0xFF98A2B3);
  static const textDisabled = Color(0xFF5A6474);
  static const offlineFg = Color(0xFF34C77B);
  static const offlineBg = Color(0xFF12251B);
}

/// Spacing scale: 4 / 8 / 12 / 16 / 24 / 32.
abstract final class Sp {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double screen = 16;
}

abstract final class Radii {
  static const double card = 12;
  static const double sheet = 20;
  static const double pill = 999;
}

/// Tap targets: 48 dp minimum, 56 dp for anything used at the counter.
abstract final class Tap {
  static const double min = 48;
  static const double counter = 56;
  static const double shutter = 72;
}

const _font = 'Inter';

/// Type scale (doc 04 §2). `mono` = tabular figures for every number.
abstract final class AppText {
  static const display = TextStyle(
      fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const title = TextStyle(
      fontFamily: _font, fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const heading = TextStyle(
      fontFamily: _font, fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const body = TextStyle(
      fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const label = TextStyle(
      fontFamily: _font,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      color: AppColors.textSecondary);
  static const mono = TextStyle(
      fontFamily: _font,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFeatures: [FontFeature.tabularFigures()]);
  static const monoDisplay = TextStyle(
      fontFamily: _font,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontFeatures: [FontFeature.tabularFigures()]);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.textPrimary,
    secondary: AppColors.info,
    onSecondary: AppColors.textPrimary,
    error: AppColors.danger,
    onError: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    outline: AppColors.border,
    surfaceContainerHighest: AppColors.surfaceAlt,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    canvasColor: AppColors.bg,
    fontFamily: _font,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      displayLarge: AppText.display,
      titleLarge: AppText.title,
      titleMedium: AppText.heading,
      bodyMedium: AppText.body,
      bodyLarge: AppText.body,
      labelMedium: AppText.label,
      labelLarge: AppText.heading,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.title,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.card))),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBackgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet))),
      showDragHandle: true,
      dragHandleColor: AppColors.border,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.primaryDim,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size.fromHeight(Tap.counter),
        textStyle: AppText.heading,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.card))),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size.fromHeight(Tap.min),
        textStyle: AppText.heading,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.card))),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(Tap.min, Tap.min),
        textStyle: AppText.heading,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(Tap.min, Tap.min),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      extendedTextStyle: AppText.heading,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      hintStyle: TextStyle(color: AppColors.textDisabled),
      labelStyle: AppText.label,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.card)),
          borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.card)),
          borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.card)),
          borderSide: BorderSide(color: AppColors.primary)),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.textPrimary,
      iconColor: AppColors.textSecondary,
      minVerticalPadding: Sp.md,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceAlt,
      contentTextStyle: AppText.body,
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceAlt,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.surfaceAlt,
      thumbColor: AppColors.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primaryDim : AppColors.surfaceAlt),
    ),
  );
}

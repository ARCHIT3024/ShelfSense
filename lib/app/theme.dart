import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens — the single source of truth (doc 04 §2).
///
/// Two palettes: dark is what the app was designed on; light was added for
/// bright counters. Screens keep reading `AppColors.x` / `AppText.x`; those
/// now resolve against [AppPalette.current], which [applyPalette] swaps
/// before the tree rebuilds. No hardcoded colours anywhere else in the app.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.primary,
    required this.primaryDim,
    required this.onPrimary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.offlineFg,
    required this.offlineBg,
  });

  final Brightness brightness;
  final Color bg, surface, surfaceAlt, border;
  final Color primary, primaryDim, onPrimary;
  final Color success, warning, danger, info;
  final Color textPrimary, textSecondary, textDisabled;
  final Color offlineFg, offlineBg;

  static const dark = AppPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF0E1013),
    surface: Color(0xFF171A1F),
    surfaceAlt: Color(0xFF1F242B),
    border: Color(0xFF2A3039),
    primary: Color(0xFFFF6B2C),
    primaryDim: Color(0xFF8A3A18),
    onPrimary: Color(0xFFF2F4F7),
    success: Color(0xFF34C77B),
    warning: Color(0xFFF5A524),
    danger: Color(0xFFE5484D),
    info: Color(0xFF4C8DFF),
    textPrimary: Color(0xFFF2F4F7),
    textSecondary: Color(0xFF98A2B3),
    textDisabled: Color(0xFF5A6474),
    offlineFg: Color(0xFF34C77B),
    offlineBg: Color(0xFF12251B),
  );

  // Status colours are darkened so they hold ≥ 4.5:1 on the off-white bg
  // (doc 04 §6): against 0xF6F7F9 success 0x177A4A ≈ 5.0, warning 0x9A5A00
  // ≈ 5.1, danger 0xC22E34 ≈ 5.3, info 0x1F5FCC ≈ 5.5, textSecondary ≈ 5.6
  // (checked in test/app/theme_test.dart).
  static const light = AppPalette(
    brightness: Brightness.light,
    bg: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF0F3),
    border: Color(0xFFD7DBE1),
    primary: Color(0xFFE85A1B),
    primaryDim: Color(0xFFF3B79A),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF177A4A),
    warning: Color(0xFF9A5A00),
    danger: Color(0xFFC22E34),
    info: Color(0xFF1F5FCC),
    textPrimary: Color(0xFF14171C),
    textSecondary: Color(0xFF5B6472),
    textDisabled: Color(0xFF9AA3B0),
    offlineFg: Color(0xFF177A4A),
    offlineBg: Color(0xFFDDF3E6),
  );

  /// The palette every token getter resolves against. Set via [applyPalette].
  static AppPalette current = dark;

  static AppPalette of(Brightness b) =>
      b == Brightness.dark ? dark : light;
}

/// Colour tokens. Getters, not consts: they follow [AppPalette.current].
abstract final class AppColors {
  static Color get bg => AppPalette.current.bg;
  static Color get surface => AppPalette.current.surface;
  static Color get surfaceAlt => AppPalette.current.surfaceAlt;
  static Color get border => AppPalette.current.border;
  static Color get primary => AppPalette.current.primary;
  static Color get primaryDim => AppPalette.current.primaryDim;

  /// Text/icon colour on a `primary` fill (light in both palettes).
  static Color get onPrimary => AppPalette.current.onPrimary;
  static Color get success => AppPalette.current.success;
  static Color get warning => AppPalette.current.warning;
  static Color get danger => AppPalette.current.danger;
  static Color get info => AppPalette.current.info;
  static Color get textPrimary => AppPalette.current.textPrimary;
  static Color get textSecondary => AppPalette.current.textSecondary;
  static Color get textDisabled => AppPalette.current.textDisabled;
  static Color get offlineFg => AppPalette.current.offlineFg;
  static Color get offlineBg => AppPalette.current.offlineBg;
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
/// Getters so the colour follows the current palette.
abstract final class AppText {
  static TextStyle get display => TextStyle(
      fontFamily: _font,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary);
  static TextStyle get title => TextStyle(
      fontFamily: _font,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static TextStyle get heading => TextStyle(
      fontFamily: _font,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static TextStyle get body => TextStyle(
      fontFamily: _font,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary);
  static TextStyle get label => TextStyle(
      fontFamily: _font,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      color: AppColors.textSecondary);
  static TextStyle get mono => TextStyle(
      fontFamily: _font,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()]);
  static TextStyle get monoDisplay => TextStyle(
      fontFamily: _font,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Makes [palette] the one every `AppColors`/`AppText` read resolves to and
/// syncs the system bars. Call before rebuilding the widget tree.
void applyPalette(AppPalette palette) {
  AppPalette.current = palette;
  final dark = palette.brightness == Brightness.dark;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: palette.brightness,
    systemNavigationBarColor: palette.bg,
    systemNavigationBarIconBrightness:
        dark ? Brightness.light : Brightness.dark,
  ));
}

/// Material theme for [palette] (defaults to the current one). Every value
/// is taken from the palette passed in, so both themes can be built
/// regardless of which palette is current.
ThemeData buildAppTheme([AppPalette? palette]) {
  final c = palette ?? AppPalette.current;
  TextStyle style(double size, FontWeight w, Color color,
          {double? spacing, List<FontFeature>? features}) =>
      TextStyle(
          fontFamily: _font,
          fontSize: size,
          fontWeight: w,
          color: color,
          letterSpacing: spacing,
          fontFeatures: features);
  final title = style(22, FontWeight.w600, c.textPrimary);
  final heading = style(17, FontWeight.w600, c.textPrimary);
  final body = style(15, FontWeight.w400, c.textPrimary);
  final label = style(13, FontWeight.w500, c.textSecondary, spacing: 0.3);
  final isDark = c.brightness == Brightness.dark;

  final scheme = ColorScheme(
    brightness: c.brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    secondary: c.info,
    onSecondary: c.onPrimary,
    error: c.danger,
    onError: c.onPrimary,
    surface: c.surface,
    onSurface: c.textPrimary,
    outline: c.border,
    surfaceContainerHighest: c.surfaceAlt,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      titleTextStyle: heading,
      contentTextStyle: body,
    ),
    fontFamily: _font,
    splashFactory: InkSparkle.splashFactory,
    textTheme: TextTheme(
      displayLarge: style(32, FontWeight.w700, c.textPrimary),
      titleLarge: title,
      titleMedium: heading,
      bodyMedium: body,
      bodyLarge: body,
      labelMedium: label,
      labelLarge: heading,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: title,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.card))),
    ),
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      modalBackgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(Radii.sheet))),
      showDragHandle: true,
      dragHandleColor: c.border,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        disabledBackgroundColor: c.primaryDim,
        disabledForegroundColor: c.textSecondary,
        minimumSize: const Size.fromHeight(Tap.counter),
        textStyle: heading,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.card))),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.textPrimary,
        side: BorderSide(color: c.border),
        minimumSize: const Size.fromHeight(Tap.min),
        textStyle: heading,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.card))),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: const Size(Tap.min, Tap.min),
        textStyle: heading,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.textPrimary,
        minimumSize: const Size(Tap.min, Tap.min),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      extendedTextStyle: heading,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceAlt,
      hintStyle: TextStyle(color: c.textDisabled),
      labelStyle: label,
      border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
          borderSide: BorderSide(color: c.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
          borderSide: BorderSide(color: c.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
          borderSide: BorderSide(color: c.primary)),
    ),
    listTileTheme: ListTileThemeData(
      textColor: c.textPrimary,
      iconColor: c.textSecondary,
      minVerticalPadding: Sp.md,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.surfaceAlt,
      contentTextStyle: body,
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.surfaceAlt,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: c.primary,
      inactiveTrackColor: c.surfaceAlt,
      thumbColor: c.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? c.primary : c.textSecondary),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? c.primaryDim : c.surfaceAlt),
    ),
  );
}

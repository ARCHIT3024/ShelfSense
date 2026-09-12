import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/app/theme.dart';
import 'package:shelfsense/app/theme_mode.dart';

void main() {
  tearDown(() => AppPalette.current = AppPalette.dark);

  test('light and dark palettes are distinct and correctly bright', () {
    expect(AppPalette.light.bg, isNot(AppPalette.dark.bg));
    expect(AppPalette.light.brightness, Brightness.light);
    expect(AppPalette.dark.brightness, Brightness.dark);
    expect(AppPalette.of(Brightness.light), same(AppPalette.light));
  });

  test('tokens and text styles follow the current palette', () {
    AppPalette.current = AppPalette.dark;
    expect(AppColors.bg, AppPalette.dark.bg);
    expect(AppText.heading.color, AppPalette.dark.textPrimary);

    AppPalette.current = AppPalette.light;
    expect(AppColors.bg, AppPalette.light.bg);
    expect(AppText.heading.color, AppPalette.light.textPrimary);
    expect(AppText.label.color, AppPalette.light.textSecondary);
  });

  test('buildAppTheme uses the requested palette, not the current one', () {
    AppPalette.current = AppPalette.dark;
    final light = buildAppTheme(AppPalette.light);
    expect(light.brightness, Brightness.light);
    expect(light.scaffoldBackgroundColor, AppPalette.light.bg);
    expect(light.appBarTheme.titleTextStyle?.color,
        AppPalette.light.textPrimary);
    // Building the light theme must not flip the current palette.
    expect(AppPalette.current, same(AppPalette.dark));
  });

  test('light status colours keep >= 4.5:1 on the light background', () {
    double lum(Color c) {
      double ch(double v) =>
          v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
      return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
    }

    double contrast(Color a, Color b) {
      final la = lum(a), lb = lum(b);
      final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    final p = AppPalette.light;
    for (final c in [
      p.success,
      p.warning,
      p.danger,
      p.info,
      p.textPrimary,
      p.textSecondary
    ]) {
      expect(contrast(c, p.bg), greaterThanOrEqualTo(4.5),
          reason: 'colour $c on ${p.bg}');
    }
  });

  test('theme mode parsing and resolution', () {
    expect(parseThemeMode('light'), ThemeMode.light);
    expect(parseThemeMode('dark'), ThemeMode.dark);
    expect(parseThemeMode(null), ThemeMode.system);
    expect(parseThemeMode('garbage'), ThemeMode.system);
    expect(resolveBrightness(ThemeMode.system, Brightness.light),
        Brightness.light);
    expect(resolveBrightness(ThemeMode.dark, Brightness.light),
        Brightness.dark);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logger.dart';
import 'di.dart';

const _tag = 'ThemeMode';
const kThemeModeKey = 'theme_mode';

/// Appearance preference: system / light / dark. Persisted in
/// `app_settings` under [kThemeModeKey]; loaded once at start by
/// [ThemeModeNotifier.load]. The palette itself is swapped by the app root
/// (see `main.dart`), which knows the platform brightness.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  Future<void> load() async {
    try {
      final v = await ref.read(dbProvider).getSetting(kThemeModeKey);
      final mode = parseThemeMode(v);
      if (mode != state) state = mode;
    } catch (e) {
      AppLogger.e(_tag, 'Load failed', e);
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      await ref.read(dbProvider).setSetting(kThemeModeKey, mode.name);
    } catch (e) {
      AppLogger.e(_tag, 'Persist failed', e);
    }
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// `'light' | 'dark' | 'system'` → [ThemeMode]; anything else is system.
ThemeMode parseThemeMode(String? v) => switch (v) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

/// The brightness a [ThemeMode] resolves to given the platform's.
Brightness resolveBrightness(ThemeMode mode, Brightness platform) =>
    switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platform,
    };

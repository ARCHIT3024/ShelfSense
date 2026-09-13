/// Single source of truth for all ML thresholds (TRD §4.1).
/// Overridable at runtime from the Diagnostics screen via AppSettings.
library;

// Detector
const double kDetConfThreshold = 0.25; // large-object scenes sit 0.25-0.4; NMS removes the extras
const double kDetNmsIou = 0.50;
const int kDetMaxBoxes = 300; // dense supermarket shelves exceed 100; NMS cost is trivial

// Matcher
const double kMatchHigh = 0.55; // 17-SKU index: runner-up sits ~0.4-0.5; live correct hits land 0.51-0.85
const double kMatchLow = 0.40; // below this = unmatched

// Enrolment
const int kMinEnrolShots = 3;
const int kTargetEnrolShots = 8;

// Gap detection (fraction of image area)
const double kGapMinArea = 0.004;

/// Context labels for enrolment shots.
const List<String> kEnrolContexts = ['bright', 'dim', 'angled', 'occluded'];

// ---------------------------------------------------------------------------
// Runtime overrides (Diagnostics sliders, T-25)
// ---------------------------------------------------------------------------

/// The live thresholds. Defaults are the `k*` constants above; the
/// Diagnostics screen changes them at runtime and persists to `app_settings`
/// so retuning against the physical shelf never needs a rebuild.
///
/// Pure Dart on purpose (no drift import): the persistence hook is injected
/// by `di.dart` so this stays unit-testable.
class RuntimeThresholds {
  RuntimeThresholds({this.persist});

  /// Called with (key, value) after every change; `null` in tests.
  final Future<void> Function(String key, String value)? persist;

  double detConf = kDetConfThreshold;
  double detNmsIou = kDetNmsIou;
  int detMaxBoxes = kDetMaxBoxes;
  double matchHigh = kMatchHigh;
  double matchLow = kMatchLow;

  final _listeners = <void Function()>[];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() {
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  /// `app_settings` keys, matching the seed in `database.dart`.
  static const keyDetConf = 'det_conf_threshold';
  static const keyDetNmsIou = 'det_nms_iou';
  static const keyDetMaxBoxes = 'det_max_boxes';
  static const keyMatchHigh = 'match_high';
  static const keyMatchLow = 'match_low';

  /// Loads from a key → value map (the `app_settings` rows). Unknown or
  /// unparsable values keep their current setting.
  void applySettings(Map<String, String> settings) {
    double d(String k, double cur) => double.tryParse(settings[k] ?? '') ?? cur;
    detConf = clampConf(d(keyDetConf, detConf));
    detNmsIou = clampIou(d(keyDetNmsIou, detNmsIou));
    detMaxBoxes = (int.tryParse(settings[keyDetMaxBoxes] ?? '') ?? detMaxBoxes)
        .clamp(1, 1000);
    final high = clampMatch(d(keyMatchHigh, matchHigh));
    final low = clampMatch(d(keyMatchLow, matchLow));
    // Reject must stay below accept; if the stored pair is inverted, keep
    // the accept value and pull reject under it.
    matchHigh = high;
    matchLow = low < high ? low : (high - 0.01).clamp(0.0, 1.0);
    _notify();
  }

  Future<void> setDetConf(double v) =>
      _set(keyDetConf, detConf = clampConf(v));
  Future<void> setDetNmsIou(double v) =>
      _set(keyDetNmsIou, detNmsIou = clampIou(v));

  Future<void> setMatchHigh(double v) async {
    matchHigh = clampMatch(v);
    if (matchLow >= matchHigh) matchLow = (matchHigh - 0.01).clamp(0.0, 1.0);
    await _set(keyMatchHigh, matchHigh);
    await _set(keyMatchLow, matchLow);
  }

  Future<void> setMatchLow(double v) async {
    matchLow = clampMatch(v);
    if (matchLow >= matchHigh) matchHigh = (matchLow + 0.01).clamp(0.0, 1.0);
    await _set(keyMatchLow, matchLow);
    await _set(keyMatchHigh, matchHigh);
  }

  Future<void> resetToDefaults() async {
    detConf = kDetConfThreshold;
    detNmsIou = kDetNmsIou;
    detMaxBoxes = kDetMaxBoxes;
    matchHigh = kMatchHigh;
    matchLow = kMatchLow;
    await _set(keyDetConf, detConf);
    await _set(keyDetNmsIou, detNmsIou);
    await _set(keyDetMaxBoxes, detMaxBoxes);
    await _set(keyMatchHigh, matchHigh);
    await _set(keyMatchLow, matchLow);
  }

  Future<void> _set(String key, num value) async {
    _notify();
    await persist?.call(key, value.toString());
  }

  static double clampConf(double v) => v.clamp(0.05, 0.95);
  static double clampIou(double v) => v.clamp(0.1, 0.9);
  static double clampMatch(double v) => v.clamp(0.0, 1.0);
}

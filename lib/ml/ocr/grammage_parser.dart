/// Pure Dart: pull pack sizes ("450 ml", "1 kg", "70g", "12 pcs") out of OCR
/// text so near-identical SKUs of the same brand can be told apart (F-22).
/// No Flutter / ML Kit imports — unit-tested on the desktop.
library;

/// A grammage in base units so sizes can be compared across units:
/// mass in grams, volume in millilitres, count in pieces.
class Grammage {
  const Grammage(this.base, this.family);

  /// Value in the family's base unit (g / ml / n).
  final double base;

  /// `g` (mass), `ml` (volume) or `n` (count).
  final String family;

  /// Builds from the app's `grammage_value` + `grammage_unit`
  /// (`g | kg | ml | l | n`). Returns null when either is missing.
  static Grammage? fromSku(double? value, String? unit) {
    if (value == null || unit == null) return null;
    return _normalise(value, unit);
  }

  /// True when [other] is the same family and within [tolerance] (fraction).
  bool matches(Grammage other, {double tolerance = 0.05}) {
    if (family != other.family) return false;
    final ref = base.abs() < 1e-9 ? 1e-9 : base;
    return ((base - other.base).abs() / ref) <= tolerance;
  }

  @override
  String toString() => '$base $family';

  @override
  bool operator ==(Object other) =>
      other is Grammage && other.base == base && other.family == family;

  @override
  int get hashCode => Object.hash(base, family);
}

Grammage? _normalise(double value, String unit) {
  switch (unit.toLowerCase()) {
    case 'g':
    case 'gm':
    case 'gms':
    case 'gram':
    case 'grams':
      return Grammage(value, 'g');
    case 'kg':
    case 'kgs':
    case 'kilo':
      return Grammage(value * 1000, 'g');
    case 'ml':
      return Grammage(value, 'ml');
    case 'l':
    case 'lt':
    case 'ltr':
    case 'litre':
    case 'liter':
    case 'litres':
    case 'liters':
      return Grammage(value * 1000, 'ml');
    case 'n':
    case 'pc':
    case 'pcs':
    case 'piece':
    case 'pieces':
    case 'nos':
      return Grammage(value, 'n');
  }
  return null;
}

// Number, optional space, unit — and the unit must NOT be followed by another
// letter (so "45 gsm" or "1 mg" don't match) or preceded by one ("FC27" is
// not "27" + anything; "27pcs" is fine because the number is the boundary).
final _pattern = RegExp(
  r'(?<![A-Za-z0-9.])(\d+(?:[.,]\d+)?)\s*'
  r'(kgs?|kilo|gms?|grams?|g|ml|ltr|lt|litres?|liters?|l|pcs?|pieces?|nos|n)'
  r'(?![A-Za-z])',
  caseSensitive: false,
);

/// Repairs the substitutions OCR makes inside a size token: capital O / lower
/// o for 0, I / l / | for 1 within a digit run, and `mI` / `mL` for `ml`.
String _repair(String text) {
  var t = text;
  // "45Oml" / "1OO g" → "450ml" / "100 g": a run of O's glued to a digit and
  // followed by more digits or a unit.
  t = t.replaceAllMapped(
    RegExp(r'(?<=\d)[Oo]+(?=\d|\s*(?:ml|mI|mL|gms?|g|kgs?|ltr|lt|l|L)\b)'),
    (m) => '0' * m.group(0)!.length,
  );
  // "5I0 g" → "510 g".
  t = t.replaceAllMapped(RegExp(r'(?<=\d)[Il|](?=\d)'), (_) => '1');
  // "450 mI" / "450 mL" → "450 ml".
  t = t.replaceAllMapped(RegExp(r'(?<=\d\s?)m[Il]\b'), (_) => 'ml');
  return t;
}

/// Every plausible pack size found in [ocrText], de-duplicated, in order of
/// appearance. Empty when nothing looks like a size.
List<Grammage> parseGrammages(String ocrText) {
  final out = <Grammage>[];
  for (final m in _pattern.allMatches(_repair(ocrText))) {
    final value = double.tryParse(m.group(1)!.replaceAll(',', '.'));
    if (value == null || value <= 0) continue;
    final g = _normalise(value, m.group(2)!);
    if (g == null) continue;
    // Guard against absurd reads ("2026 g" from a date, "9876543210 ml").
    if (g.family == 'n' ? g.base > 500 : g.base > 50000) continue;
    if (!out.contains(g)) out.add(g);
  }
  return out;
}

/// Given the sizes read off a crop and the candidates' sizes, returns the
/// index of the single candidate whose size is present in the text, or null
/// when zero or more than one candidate is supported (never guess).
int? pickByGrammage(List<Grammage> read, List<Grammage?> candidates,
    {double tolerance = 0.05}) {
  int? hit;
  for (var i = 0; i < candidates.length; i++) {
    final c = candidates[i];
    if (c == null) continue;
    if (read.any((r) => r.matches(c, tolerance: tolerance))) {
      if (hit != null) return null; // ambiguous
      hit = i;
    }
  }
  return hit;
}

/// Deterministic visit record — the non-LLM half of T-26.
///
/// TRD §5.5 rule 5: on any LLM failure (or with no LLM loaded at all) the
/// app falls back to a templated summary. This is that template. Every
/// number here is computed from the shelf facts and order lines — nothing is
/// invented — so it is also the reference the LLM's free-text fields are
/// validated against. Copy follows 04_UIUX §7: plain, short, never "AI".
library;

import 'package:intl/intl.dart';

import '../../domain/models/models.dart';
import 'llm_service.dart';

/// Structured visit record built from deterministic data (TRD §5.5 fields
/// the LLM is *not* allowed to override).
class VisitFacts {
  const VisitFacts({
    required this.stockouts,
    required this.belowPlan,
    required this.inStock,
    required this.unlisted,
    required this.lineCount,
    required this.totalValuePaise,
    required this.overrides,
  });

  final int stockouts, belowPlan, inStock, unlisted;
  final int lineCount, totalValuePaise;

  /// (skuName, suggested, final) for each rep-edited line.
  final List<(String, int, int)> overrides;

  int get packsExpected => stockouts + belowPlan + inStock;

  Map<String, Object?> toJson() => {
        'stockouts': stockouts,
        'below_plan': belowPlan,
        'in_stock': inStock,
        'unlisted': unlisted,
        'line_count': lineCount,
        'total_value_paise': totalValuePaise,
        'overrides': [
          for (final o in overrides)
            {'sku': o.$1, 'suggested': o.$2, 'final': o.$3},
        ],
      };
}

/// Produces [VisitFacts] plus prose without any model. Safe to call on the
/// UI thread; pure string work.
final class DeterministicVisitRecordService {
  const DeterministicVisitRecordService();

  static final _money = NumberFormat('#,##0');

  VisitFacts facts({
    required List<ShelfFact> shelfFacts,
    required List<OrderLine> lines,
  }) {
    int count(ShelfStatus s) => shelfFacts.where((f) => f.status == s).length;
    return VisitFacts(
      stockouts: count(ShelfStatus.stockout),
      belowPlan: count(ShelfStatus.belowPlan),
      inStock: count(ShelfStatus.inStock),
      unlisted: count(ShelfStatus.unlisted),
      lineCount: lines.length,
      totalValuePaise: lines.fold(0, (s, l) => s + l.valuePaise),
      overrides: [
        for (final l in lines)
          if (l.wasOverridden)
            (l.skuName ?? l.skuCode ?? l.skuId, l.suggestedQty, l.finalQty),
      ],
    );
  }

  /// Full record: shelf summary sentence + reorder rationale paragraph.
  VisitRecord record({
    required List<ShelfFact> shelfFacts,
    required List<OrderLine> lines,
    String? transcript,
  }) {
    final f = facts(shelfFacts: shelfFacts, lines: lines);
    return VisitRecord(
      summaryProse: summary(f, transcript: transcript),
      reorderRationale: rationale(f, shelfFacts: shelfFacts, lines: lines),
    );
  }

  /// "6 SKUs out of stock, 1 below plan, 4 in stock. 2 unlisted packs on shelf."
  String summary(VisitFacts f, {String? transcript}) {
    final parts = <String>[];
    if (f.packsExpected == 0 && f.unlisted == 0) {
      parts.add('No planogram data for this visit.');
    } else {
      final bits = <String>[
        if (f.stockouts > 0) '${f.stockouts} ${_sku(f.stockouts)} out of stock',
        if (f.belowPlan > 0) '${f.belowPlan} below plan',
        if (f.inStock > 0) '${f.inStock} in stock',
      ];
      if (bits.isEmpty) {
        parts.add('Nothing from the planogram was on the shelf.');
      } else {
        parts.add('${_cap(bits.join(', '))}.');
      }
      if (f.unlisted > 0) {
        parts.add('${f.unlisted} unlisted ${_pack(f.unlisted)} on shelf.');
      }
    }
    final t = transcript?.trim();
    if (t != null && t.isNotEmpty) {
      parts.add('Owner note: ${_trimNote(t)}');
    }
    return parts.join(' ');
  }

  /// "Suggested reorder of 8 lines worth ₹2,428, weighted to stockouts;
  ///  Dust Tea raised from 24 to 48 by the rep."
  String rationale(
    VisitFacts f, {
    required List<ShelfFact> shelfFacts,
    required List<OrderLine> lines,
  }) {
    if (f.lineCount == 0) {
      return f.stockouts == 0
          ? 'No reorder needed — planogram lines are in stock.'
          : 'No reorder lines drafted.';
    }
    final buf = StringBuffer(
      'Suggested reorder of ${f.lineCount} ${_line(f.lineCount)} worth '
      '₹${_money.format(f.totalValuePaise ~/ 100)}',
    );
    if (f.stockouts > 0 && f.belowPlan > 0) {
      buf.write(', covering ${f.stockouts} ${_stockout(f.stockouts)} and '
          '${f.belowPlan} below-plan');
    } else if (f.stockouts > 0) {
      buf.write(', weighted to stockouts');
    } else if (f.belowPlan > 0) {
      buf.write(', topping up below-plan lines');
    }
    if (f.overrides.isEmpty) {
      buf.write('.');
    } else {
      final edits = f.overrides.take(3).map((o) {
        final (name, sug, fin) = o;
        if (sug == 0) return '$name added at $fin';
        return '$name ${fin > sug ? 'raised' : 'lowered'} from $sug to $fin';
      }).join(', ');
      final more = f.overrides.length > 3 ? ' and ${f.overrides.length - 3} more' : '';
      buf.write('; $edits$more by the rep.');
    }
    return buf.toString();
  }

  static String _sku(int n) => n == 1 ? 'SKU' : 'SKUs';
  static String _pack(int n) => n == 1 ? 'pack' : 'packs';
  static String _line(int n) => n == 1 ? 'line' : 'lines';
  static String _stockout(int n) => n == 1 ? 'stockout' : 'stockouts';
  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  static String _trimNote(String t) =>
      t.length <= 160 ? t : '${t.substring(0, 157).trimRight()}…';
}

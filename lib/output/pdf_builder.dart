/// On-device PDF beat summary — T-29 (LLM-free half).
///
/// Rendered entirely on the handset with the pure-Dart `pdf` package and
/// handed off through the share sheet like the XLSX/CSV. The narrative
/// paragraphs come from [DeterministicVisitRecordService]; when the LLM lands
/// it only replaces those free-text fields, never the numbers (TRD §5.5).
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/failures.dart';
import '../core/logger.dart';
import '../core/result.dart';
import '../domain/models/models.dart';
import '../ml/llm/deterministic_visit_record.dart';

const _tag = 'PdfBuilder';

// Design tokens (mirror AppColors in theme.dart, printed on white)
const _kInk       = PdfColor.fromInt(0xFF0E1013);
const _kSubdued   = PdfColor.fromInt(0xFF616161);
const _kRule      = PdfColor.fromInt(0xFFBDBDBD);
const _kHeaderBg  = PdfColor.fromInt(0xFF1A237E);
const _kZebra     = PdfColor.fromInt(0xFFE8EAF6);
const _kAmberTint = PdfColor.fromInt(0xFFFFF9C4);
const _kDanger    = PdfColor.fromInt(0xFFC62828);
const _kWarning   = PdfColor.fromInt(0xFFEF6C00);
const _kInfo      = PdfColor.fromInt(0xFF1565C0);
const _kSuccess   = PdfColor.fromInt(0xFF2E7D32);

// ---------------------------------------------------------------------------
// Input model
// ---------------------------------------------------------------------------

/// One confirmed visit, already joined with names — the PDF never queries.
class PdfVisit {
  const PdfVisit({
    required this.storeName,
    required this.storeCode,
    required this.confirmedAt,
    required this.shelfFacts,
    required this.lines,
    this.summaryProse,
    this.reorderRationale,
  });

  final String storeName;
  final String storeCode;
  final DateTime confirmedAt;
  final List<ShelfFact> shelfFacts;
  final List<OrderLine> lines;

  /// Narrative from the visit row (LLM or deterministic). Null ⇒ generate
  /// deterministically here.
  final String? summaryProse;
  final String? reorderRationale;

  int get valuePaise => lines.fold(0, (s, l) => s + l.valuePaise);
  int get stockouts =>
      shelfFacts.where((f) => f.status == ShelfStatus.stockout).length;
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Builds the beat summary PDF and writes it to app storage.
/// Returns the absolute file path on success, or [ExportFailed] on error.
/// Never throws across the service boundary.
Future<Result<String, Failure>> buildBeatSummaryPdf({
  required String beatName,
  required String beatCode,
  String? repName,
  required List<PdfVisit> visits,
}) async {
  if (visits.isEmpty) {
    return Err(const ExportFailed('Cannot export: beat has no confirmed visits.'));
  }
  try {
    final font = await _loadInter();
    final bytes = await _buildPdfBytes(
      beatName: beatName, beatCode: beatCode, repName: repName,
      visits: visits, font: font,
    );
    final dir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(dir.path, 'exports'));
    if (!await exportsDir.exists()) await exportsDir.create(recursive: true);
    final fileName =
        'beat_${_slug(beatCode)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(p.join(exportsDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    AppLogger.i(_tag, 'Wrote ${file.path} (${visits.length} visits)');
    return Ok(file.path);
  } catch (e, st) {
    AppLogger.e(_tag, 'PDF build failed', e);
    return Err(ExportFailed('PDF build failed: $e\n$st'));
  }
}

/// Returns raw PDF bytes without touching the filesystem or asset bundle
/// (built-in Helvetica) — for unit tests and in-memory sharing.
Future<Result<Uint8List, Failure>> buildBeatSummaryPdfBytes({
  required String beatName,
  required String beatCode,
  String? repName,
  required List<PdfVisit> visits,
  pw.Font? font,
}) async {
  if (visits.isEmpty) {
    return Err(const ExportFailed('Cannot export: beat has no confirmed visits.'));
  }
  try {
    return Ok(await _buildPdfBytes(
      beatName: beatName, beatCode: beatCode, repName: repName,
      visits: visits, font: font,
    ));
  } catch (e, st) {
    AppLogger.e(_tag, 'PDF bytes build failed', e);
    return Err(ExportFailed('PDF build failed: $e\n$st'));
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// The bundled Inter variable font, or null to use the built-in Helvetica
/// (variable fonts are not guaranteed to parse in `pdf` 3.x).
Future<pw.Font?> _loadInter() async {
  try {
    final data = await rootBundle.load('assets/fonts/Inter-Variable.ttf');
    return pw.Font.ttf(data);
  } catch (e) {
    AppLogger.w(_tag, 'Inter not usable in PDF, falling back to Helvetica: $e');
    return null;
  }
}

String _slug(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

final _money = NumberFormat('#,##0');
final _dateFmt = DateFormat('dd MMM yyyy');
final _timeFmt = DateFormat('HH:mm');

String _rupees(int paise) => 'Rs ${_money.format(paise ~/ 100)}';

Future<Uint8List> _buildPdfBytes({
  required String beatName,
  required String beatCode,
  required String? repName,
  required List<PdfVisit> visits,
  required pw.Font? font,
}) async {
  const svc = DeterministicVisitRecordService();
  final theme = font == null
      ? pw.ThemeData.withFont()
      : pw.ThemeData.withFont(base: font, bold: font);

  final totalPaise = visits.fold(0, (s, v) => s + v.valuePaise);
  final totalLines = visits.fold(0, (s, v) => s + v.lines.length);
  final totalStockouts = visits.fold(0, (s, v) => s + v.stockouts);

  final doc = pw.Document(
    title: 'ShelfSense beat summary — $beatName',
    author: 'ShelfSense',
    theme: theme,
  );

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
    footer: (ctx) => pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'ShelfSense · generated on the handset, offline · page ${ctx.pageNumber} of ${ctx.pagesCount}',
        style: const pw.TextStyle(fontSize: 8, color: _kSubdued),
      ),
    ),
    build: (ctx) => [
      _beatHeader(
        beatName: beatName, beatCode: beatCode, repName: repName,
        visits: visits.length, lines: totalLines,
        valuePaise: totalPaise, stockouts: totalStockouts,
      ),
      pw.SizedBox(height: 18),
      for (final v in visits) ...[
        _visitSection(v, svc),
        pw.SizedBox(height: 16),
      ],
    ],
  ));

  return doc.save();
}

pw.Widget _beatHeader({
  required String beatName,
  required String beatCode,
  required String? repName,
  required int visits,
  required int lines,
  required int valuePaise,
  required int stockouts,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('ShelfSense · Beat summary',
          style: const pw.TextStyle(fontSize: 10, color: _kSubdued)),
      pw.SizedBox(height: 2),
      pw.Text(beatName,
          style: pw.TextStyle(
              fontSize: 20, fontWeight: pw.FontWeight.bold, color: _kInk)),
      pw.SizedBox(height: 2),
      pw.Text(
        [
          beatCode,
          _dateFmt.format(DateTime.now()),
          if (repName != null && repName.isNotEmpty) 'Rep: $repName',
        ].join('  ·  '),
        style: const pw.TextStyle(fontSize: 10, color: _kSubdued),
      ),
      pw.SizedBox(height: 10),
      pw.Row(children: [
        _stat('Visits', '$visits'),
        _stat('Order lines', '$lines'),
        _stat('Order value', _rupees(valuePaise)),
        _stat('Stockouts', '$stockouts', color: stockouts > 0 ? _kDanger : _kInk),
      ]),
      pw.SizedBox(height: 8),
      pw.Divider(color: _kRule, thickness: 0.5),
    ],
  );
}

pw.Widget _stat(String label, String value, {PdfColor color = _kInk}) {
  return pw.Expanded(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label.toUpperCase(),
            style: const pw.TextStyle(fontSize: 7, color: _kSubdued)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    ),
  );
}

pw.Widget _visitSection(PdfVisit v, DeterministicVisitRecordService svc) {
  final facts = svc.facts(shelfFacts: v.shelfFacts, lines: v.lines);
  // Built-in Helvetica has no rupee glyph; keep the currency readable.
  final summary = (v.summaryProse ?? svc.summary(facts)).replaceAll('₹', 'Rs ');
  final rationale = (v.reorderRationale ??
          svc.rationale(facts, shelfFacts: v.shelfFacts, lines: v.lines))
      .replaceAll('₹', 'Rs ');

  // Stockouts first, then below plan, unlisted, in stock — as on /shelf.
  int rank(ShelfStatus s) => switch (s) {
        ShelfStatus.stockout => 0,
        ShelfStatus.belowPlan => 1,
        ShelfStatus.unlisted => 2,
        ShelfStatus.inStock => 3,
      };
  final facts0 = [...v.shelfFacts]
    ..sort((a, b) {
      final r = rank(a.status).compareTo(rank(b.status));
      return r != 0 ? r : (a.skuName ?? '').compareTo(b.skuName ?? '');
    });

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(v.storeName,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold, color: _kInk)),
          pw.Text(
            '${v.storeCode}  ·  ${_timeFmt.format(v.confirmedAt)}  ·  '
            '${v.lines.length} lines  ·  ${_rupees(v.valuePaise)}',
            style: const pw.TextStyle(fontSize: 9, color: _kSubdued),
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Text(summary, style: const pw.TextStyle(fontSize: 9.5, color: _kInk)),
      pw.SizedBox(height: 6),
      if (facts0.isNotEmpty) ...[
        _shelfTable(facts0),
        pw.SizedBox(height: 6),
      ],
      if (v.lines.isNotEmpty) ...[
        _orderTable(v.lines),
        pw.SizedBox(height: 4),
      ],
      pw.Text(rationale,
          style: const pw.TextStyle(fontSize: 9.5, color: _kInk)),
      pw.SizedBox(height: 4),
      pw.Divider(color: _kRule, thickness: 0.5),
    ],
  );
}

pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Text(text,
        textAlign: align,
        style: pw.TextStyle(
            fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
  );
}

pw.Widget _cell(String text,
    {pw.TextAlign align = pw.TextAlign.left, PdfColor color = _kInk, bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
    child: pw.Text(text,
        textAlign: align,
        style: pw.TextStyle(
            fontSize: 8.5,
            color: color,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );
}

(String, PdfColor) _statusLabel(ShelfStatus s) => switch (s) {
      ShelfStatus.stockout => ('Stockout', _kDanger),
      ShelfStatus.belowPlan => ('Below plan', _kWarning),
      ShelfStatus.unlisted => ('Unlisted', _kInfo),
      ShelfStatus.inStock => ('In stock', _kSuccess),
    };

pw.Widget _shelfTable(List<ShelfFact> facts) {
  return pw.Table(
    border: pw.TableBorder.all(color: _kRule, width: 0.4),
    columnWidths: const {
      0: pw.FlexColumnWidth(4),
      1: pw.FlexColumnWidth(1),
      2: pw.FlexColumnWidth(1),
      3: pw.FlexColumnWidth(1.6),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _kHeaderBg),
        children: [
          _headerCell('Shelf — SKU'),
          _headerCell('Plan', align: pw.TextAlign.right),
          _headerCell('Found', align: pw.TextAlign.right),
          _headerCell('Status'),
        ],
      ),
      for (var i = 0; i < facts.length; i++)
        pw.TableRow(
          decoration: pw.BoxDecoration(color: i.isEven ? _kZebra : PdfColors.white),
          children: [
            _cell([
              facts[i].skuName ?? facts[i].skuId,
              if ((facts[i].grammageLabel ?? '').isNotEmpty) facts[i].grammageLabel!,
            ].join('  ')),
            _cell(
              facts[i].status == ShelfStatus.unlisted ? '–' : '${facts[i].targetFacings}',
              align: pw.TextAlign.right,
            ),
            _cell('${facts[i].detectedFacings}',
                align: pw.TextAlign.right, color: _statusLabel(facts[i].status).$2),
            _cell(_statusLabel(facts[i].status).$1,
                color: _statusLabel(facts[i].status).$2, bold: true),
          ],
        ),
    ],
  );
}

pw.Widget _orderTable(List<OrderLine> lines) {
  final total = lines.fold(0, (s, l) => s + l.valuePaise);
  return pw.Table(
    border: pw.TableBorder.all(color: _kRule, width: 0.4),
    columnWidths: const {
      0: pw.FlexColumnWidth(3.2),
      1: pw.FlexColumnWidth(1.1),
      2: pw.FlexColumnWidth(1.1),
      3: pw.FlexColumnWidth(1),
      4: pw.FlexColumnWidth(1.4),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _kHeaderBg),
        children: [
          _headerCell('Order — SKU'),
          _headerCell('Grammage'),
          _headerCell('Suggested', align: pw.TextAlign.right),
          _headerCell('Final', align: pw.TextAlign.right),
          _headerCell('Value', align: pw.TextAlign.right),
        ],
      ),
      for (var i = 0; i < lines.length; i++)
        pw.TableRow(
          // Overridden lines get the same amber tint as the XLSX.
          decoration: pw.BoxDecoration(
            color: lines[i].wasOverridden
                ? _kAmberTint
                : (i.isEven ? _kZebra : PdfColors.white),
          ),
          children: [
            _cell(
              '${lines[i].skuName ?? lines[i].skuCode ?? lines[i].skuId}'
              '${lines[i].wasOverridden ? '  *' : ''}',
            ),
            _cell(lines[i].grammageLabel ?? ''),
            _cell('${lines[i].suggestedQty}', align: pw.TextAlign.right, color: _kSubdued),
            _cell('${lines[i].finalQty}', align: pw.TextAlign.right, bold: true),
            _cell(_rupees(lines[i].valuePaise), align: pw.TextAlign.right),
          ],
        ),
      pw.TableRow(
        children: [
          _cell('Total  (* edited by rep)', bold: true),
          _cell(''),
          _cell(''),
          _cell('${lines.fold(0, (s, l) => s + l.finalQty)}',
              align: pw.TextAlign.right, bold: true),
          _cell(_rupees(total), align: pw.TextAlign.right, bold: true),
        ],
      ),
    ],
  );
}

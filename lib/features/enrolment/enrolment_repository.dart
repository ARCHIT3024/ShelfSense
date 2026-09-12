import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/ids.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../../data/db/database.dart';
import '../../ml/common/thresholds.dart';
import '../../ml/embedder/embedder_service.dart';

const _tag = 'EnrolRepo';

/// One enrolment shot. The crop file on disk is the source of truth; the
/// `sku_embeddings` row exists only once the embedder has run on it, so
/// shots taken before the model lands can be back-filled later.
class EnrolShot {
  const EnrolShot({
    required this.path,
    required this.context,
    required this.embedded,
  });
  final String path;
  final String context; // one of kEnrolContexts
  final bool embedded;
}

class EnrolmentRepository {
  EnrolmentRepository(this.db, this.embedder, {this.index});
  final AppDatabase db;
  final EmbedderService? embedder;

  /// Refreshed after any embedding change so the next shelf photo sees the
  /// new pack at once. Optional so the start-up back-fill can run before
  /// the index exists.
  final SkuIndex? index;

  // ---- SKUs -------------------------------------------------------------

  Future<List<SkusData>> activeSkus() {
    return (db.select(db.skus)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm.asc(t.isEnrolled), // un-enrolled first
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
  }

  Future<SkusData?> skuById(String id) {
    return (db.select(db.skus)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<SkusData> createSku({
    required String name,
    String? brand,
    String? category,
    double? grammageValue,
    String? grammageUnit,
    String? variant,
    int mrpPaise = 0,
    int caseSize = 1,
  }) async {
    final id = newId();
    final code = await _uniqueCode(name, grammageValue, grammageUnit);
    await db.into(db.skus).insert(SkusCompanion.insert(
          id: id,
          code: code,
          name: name.trim(),
          brand: Value(_nullIfBlank(brand)),
          category: Value(_nullIfBlank(category)),
          grammageValue: Value(grammageValue),
          grammageUnit: Value(_nullIfBlank(grammageUnit)),
          variant: Value(_nullIfBlank(variant)),
          mrpPaise: Value(mrpPaise),
          caseSize: Value(caseSize),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
    AppLogger.i(_tag, 'Created SKU $code ($name)');
    return (await skuById(id))!;
  }

  /// `NDL-70` style: first word of the name, upper-cased, plus grammage.
  Future<String> _uniqueCode(
      String name, double? grammage, String? unit) async {
    final word = name
        .trim()
        .split(RegExp(r'\s+'))
        .first
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    final stem = word.isEmpty ? 'SKU' : word.substring(0, word.length.clamp(0, 6));
    final g = grammage == null
        ? ''
        : '-${grammage == grammage.floorToDouble() ? grammage.toInt() : grammage}'
            '${(unit ?? '').toUpperCase()}';
    final base = '$stem$g';
    var code = base;
    var n = 2;
    while (await (db.select(db.skus)..where((t) => t.code.equals(code)))
            .getSingleOrNull() !=
        null) {
      code = '$base-${n++}';
    }
    return code;
  }

  static String? _nullIfBlank(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  // ---- Shots ------------------------------------------------------------

  Future<Directory> _shotDir(String skuId) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'enrol', skuId));
    await dir.create(recursive: true);
    return dir;
  }

  /// Shots on disk for [skuId], joined with whether an embedding row exists.
  Future<List<EnrolShot>> shots(String skuId) async {
    final dir = await _shotDir(skuId);
    final embedded = await (db.select(db.skuEmbeddings)
          ..where((t) => t.skuId.equals(skuId) & t.isActive.equals(true)))
        .get();
    final embeddedPaths = embedded.map((e) => e.sourceImagePath).toSet();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    return [
      for (final f in files)
        EnrolShot(
          path: f.path,
          context: _contextFromName(f.path),
          embedded: embeddedPaths.contains(f.path),
        ),
    ];
  }

  // Filenames are `<millis>_<context>.jpg` so context survives without a table.
  static String _contextFromName(String path) {
    final name = p.basenameWithoutExtension(path);
    final idx = name.lastIndexOf('_');
    final ctx = idx == -1 ? '' : name.substring(idx + 1);
    return kEnrolContexts.contains(ctx) ? ctx : kEnrolContexts.first;
  }

  /// Copies [cropPath] into the SKU's shot folder, embeds it if the model is
  /// available, and updates `is_enrolled`. Returns the stored shot.
  Future<EnrolShot> addShot({
    required String skuId,
    required String cropPath,
    required String context,
  }) async {
    final dir = await _shotDir(skuId);
    final dest = p.join(
        dir.path, '${DateTime.now().millisecondsSinceEpoch}_$context.jpg');
    await File(cropPath).copy(dest);

    var embedded = false;
    final e = embedder;
    if (e != null && e.isLoaded) {
      switch (await e.embed(dest)) {
        case Ok(:final value):
          await _insertEmbedding(skuId, dest, context, value);
          embedded = true;
        case Err(:final failure):
          AppLogger.w(_tag, 'Embed failed for $dest — $failure (crop kept)');
      }
    }
    await refreshEnrolledFlag(skuId);
    if (embedded) await index?.refresh();
    return EnrolShot(path: dest, context: context, embedded: embedded);
  }

  Future<void> removeShot(String skuId, EnrolShot shot) async {
    await (db.delete(db.skuEmbeddings)
          ..where((t) => t.sourceImagePath.equals(shot.path)))
        .go();
    final f = File(shot.path);
    if (await f.exists()) await f.delete();
    await refreshEnrolledFlag(skuId);
    await index?.refresh();
  }

  Future<void> _insertEmbedding(
      String skuId, String path, String context, List<double> vector) {
    final bytes = Float32List.fromList(vector).buffer.asUint8List();
    return db.into(db.skuEmbeddings).insert(SkuEmbeddingsCompanion.insert(
          id: newId(),
          skuId: skuId,
          vector: bytes,
          sourceImagePath: Value(path),
          captureContext: Value(context),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
  }

  /// `is_enrolled` ⇔ ≥ kMinEnrolShots active embeddings (05_DATA_SCHEMA §3).
  Future<int> refreshEnrolledFlag(String skuId) async {
    final count = (await (db.select(db.skuEmbeddings)
              ..where((t) => t.skuId.equals(skuId) & t.isActive.equals(true)))
            .get())
        .length;
    await (db.update(db.skus)..where((t) => t.id.equals(skuId))).write(
        SkusCompanion(isEnrolled: Value(count >= kMinEnrolShots)));
    return count;
  }

  /// Embeds every shot on disk that has no embedding row yet. Call once
  /// after the embedder loads (T-20) so shots taken before the model
  /// existed become recognisable without re-shooting.
  Future<int> backfillPendingEmbeddings() async {
    final e = embedder;
    if (e == null || !e.isLoaded) return 0;
    var done = 0;
    for (final sku in await activeSkus()) {
      for (final shot in await shots(sku.id)) {
        if (shot.embedded) continue;
        if (await e.embed(shot.path) case Ok(:final value)) {
          await _insertEmbedding(sku.id, shot.path, shot.context, value);
          done++;
        }
      }
      await refreshEnrolledFlag(sku.id);
    }
    AppLogger.i(_tag, 'Back-filled $done embeddings');
    if (done > 0) await index?.refresh();
    return done;
  }

  // ---- Hand-off back to /review -----------------------------------------

  /// Tags the detection the rep enrolled from, so the box turns green the
  /// moment they return.
  Future<void> tagDetection(String detectionId, String skuId) async {
    final d = await (db.select(db.detections)
          ..where((t) => t.id.equals(detectionId)))
        .getSingleOrNull();
    if (d == null) return;
    await (db.update(db.detections)..where((t) => t.id.equals(detectionId)))
        .write(DetectionsCompanion(
      skuId: Value(skuId),
      matchConfidence: const Value(1.0),
      matchMethod: const Value('manual'),
      wasCorrected: const Value(true),
    ));
    await db.into(db.overrideEvents).insert(OverrideEventsCompanion.insert(
          id: newId(),
          visitId: d.visitId,
          entity: 'detection',
          entityId: detectionId,
          field: 'sku_id',
          oldValue: Value(d.skuId),
          newValue: Value(skuId),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
  }
}

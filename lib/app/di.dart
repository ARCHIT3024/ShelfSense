import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import '../ml/embedder/embedder_service.dart';

/// Global database provider — single instance for the app lifetime.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// SKU recogniser (T-20). `null` until the embedder model + service land —
/// consumers must degrade gracefully (enrolment stores crops only, the
/// picker shows no ranked candidates).
final embedderProvider = Provider<EmbedderService?>((ref) => null);

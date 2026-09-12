import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';

/// Global database provider — single instance for the app lifetime.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

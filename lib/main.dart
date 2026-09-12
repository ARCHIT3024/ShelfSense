import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/di.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'data/db/database.dart';
import 'data/seed/seed_data.dart';
import 'core/logger.dart';
import 'core/result.dart';
import 'features/enrolment/enrolment_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait lock — enforced in AndroidManifest too, but belt-and-suspenders.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Status bar: light icons on dark background.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  AppLogger.i('Main', 'App starting');

  runApp(
    ProviderScope(
      overrides: [
        // Kick-off seed when the DB is first read.
        dbProvider.overrideWith((ref) {
          final db = AppDatabase();
          ref.onDispose(db.close);
          // Fire-and-forget seed — boot screen waits for it.
          runSeed(db);
          return db;
        }),
      ],
      child: const ShelfSenseApp(),
    ),
  );
}

class ShelfSenseApp extends ConsumerStatefulWidget {
  const ShelfSenseApp({super.key});

  @override
  ConsumerState<ShelfSenseApp> createState() => _ShelfSenseAppState();
}

class _ShelfSenseAppState extends ConsumerState<ShelfSenseApp> {
  @override
  void initState() {
    super.initState();
    // Models load lazily and independently (TRD §4.3): start the detector
    // now so the first shutter press finds it ready, but never block the
    // UI or the app start on it. A missing/invalid model just logs.
    ref.read(detectorProvider)?.load();
    _loadRecogniser();
  }

  /// Embedder → back-fill embeddings for shots taken before the model
  /// existed → load the index. Fire-and-forget; each step logs on failure.
  Future<void> _loadRecogniser() async {
    final embedder = ref.read(embedderProvider);
    if (embedder == null) return;
    if (await embedder.load() case Err()) return;
    try {
      await EnrolmentRepository(ref.read(dbProvider), embedder)
          .backfillPendingEmbeddings();
    } catch (e) {
      AppLogger.e('Main', 'Embedding back-fill failed', e);
    }
    await ref.read(skuIndexProvider).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShelfSense',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}

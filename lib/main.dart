import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/di.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'app/theme_mode.dart';
import 'data/db/database.dart';
import 'data/seed/seed_data.dart';
import 'core/logger.dart';
import 'core/result.dart';
import 'features/enrolment/enrolment_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait lock — enforced in AndroidManifest too, but belt-and-suspenders.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Dark until the persisted appearance mode is read (see ShelfSenseApp).
  applyPalette(AppPalette.dark);

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

class _ShelfSenseAppState extends ConsumerState<ShelfSenseApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Models load lazily and independently (TRD §4.3): start the detector
    // now so the first shutter press finds it ready, but never block the
    // UI or the app start on it. A missing/invalid model just logs.
    _loadThresholds();
    ref.read(themeModeProvider.notifier).load();
    ref.read(detectorProvider)?.load();
    _loadRecogniser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// OS light/dark switch — only matters in system mode, harmless otherwise.
  @override
  void didChangePlatformBrightness() => setState(() {});

  /// Persisted slider values from /diagnostics → live thresholds.
  Future<void> _loadThresholds() async {
    try {
      final db = ref.read(dbProvider);
      final rows = await db.select(db.appSettings).get();
      ref
          .read(thresholdsProvider)
          .applySettings({for (final r in rows) r.key: r.value});
    } catch (e) {
      AppLogger.e('Main', 'Threshold load failed', e);
    }
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
    final mode = ref.watch(themeModeProvider);
    // Screens read AppColors/AppText at build time, so the palette must be
    // current *before* the tree below builds, and the whole tree must
    // rebuild when it changes — hence the keyed subtree. In system mode this
    // also tracks the OS switching (platformBrightness is an inherited
    // dependency of this build).
    final platform =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final brightness = resolveBrightness(mode, platform);
    final palette = AppPalette.of(brightness);
    if (!identical(AppPalette.current, palette)) applyPalette(palette);

    return MaterialApp.router(
      key: ValueKey(brightness),
      title: 'ShelfSense',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: buildAppTheme(AppPalette.light),
      darkTheme: buildAppTheme(AppPalette.dark),
      routerConfig: appRouter,
    );
  }
}

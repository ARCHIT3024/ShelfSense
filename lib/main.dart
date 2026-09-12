import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/di.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'data/db/database.dart';
import 'data/seed/seed_data.dart';
import 'core/logger.dart';

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

class ShelfSenseApp extends StatelessWidget {
  const ShelfSenseApp({super.key});

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

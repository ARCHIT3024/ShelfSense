import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/beat/beat_screen.dart';
import '../features/store/store_screen.dart';
import '../features/capture/capture_screen.dart';
import '../features/review/review_screen.dart';
import '../features/shelf_report/shelf_report_screen.dart';
import '../features/order/order_screen.dart';
import '../features/enrolment/enrolment_screen.dart';
import '../features/export/export_screen.dart';
import '../features/handover/handover_screen.dart';
import '../features/benchmark/benchmark_screen.dart';
import '../features/catalogue/catalogue_screen.dart';
import '../features/diagnostics/diagnostics_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/beat',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: '/beat',
      builder: (_, _) => const BeatScreen(),
    ),
    GoRoute(
      path: '/store/:storeId',
      builder: (_, state) =>
          StoreScreen(storeId: state.pathParameters['storeId']!),
    ),
    GoRoute(
      path: '/capture/:visitId',
      builder: (_, state) =>
          CaptureScreen(visitId: state.pathParameters['visitId']!),
    ),
    GoRoute(
      path: '/review/:visitId',
      builder: (_, state) => ReviewScreen(
        visitId: state.pathParameters['visitId']!,
        focusSkuId: state.uri.queryParameters['sku'],
      ),
    ),
    GoRoute(
      path: '/shelf/:visitId',
      builder: (_, state) =>
          ShelfReportScreen(visitId: state.pathParameters['visitId']!),
    ),
    GoRoute(
      path: '/order/:visitId',
      builder: (_, state) =>
          OrderScreen(visitId: state.pathParameters['visitId']!),
    ),
    GoRoute(
      path: '/enrol',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return EnrolmentScreen(
          skuId: extra?['skuId'] as String?,
          preloadedCropPath: extra?['cropPath'] as String?,
          detectionId: extra?['detectionId'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/export',
      builder: (_, _) => const ExportScreen(),
    ),
    GoRoute(
      path: '/catalogue',
      builder: (_, _) => const CatalogueScreen(),
    ),
    GoRoute(
      path: '/handover',
      builder: (_, _) => const HandoverScreen(),
    ),
    GoRoute(
      path: '/benchmark',
      builder: (_, _) => const BenchmarkScreen(),
    ),
    GoRoute(
      path: '/diagnostics',
      builder: (_, _) => const DiagnosticsScreen(),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(
      child: Text('That screen does not exist.\n${state.error}'),
    ),
  ),
);

import 'dart:io';

// Transitive deps (via printing / share_plus) — used only on this screen.
// ignore_for_file: depend_on_referenced_packages
import 'package:archive/archive_io.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/di.dart';
import '../../app/theme.dart';
import '../../app/theme_mode.dart';
import '../../core/logger.dart';
import '../../ml/detector/tflite_detector.dart';
import '../../ml/embedder/tflite_embedder.dart';

const _tag = 'Diagnostics';

/// `/diagnostics` — model status, live thresholds (T-25), connectivity,
/// and the danger zone (04_UIUX_DESIGN §`/diagnostics`). Never shown to a
/// shop owner; it is the crew's screen between demo runs.
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  bool _busy = false;
  String? _connectivity;
  String? _version;
  ({int skus, int enrolled, int visits})? _counts;

  @override
  void initState() {
    super.initState();
    ref.read(thresholdsProvider).addListener(_onThresholds);
    _loadInfo();
  }

  @override
  void dispose() {
    ref.read(thresholdsProvider).removeListener(_onThresholds);
    super.dispose();
  }

  void _onThresholds() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInfo() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final names = results
          .where((r) => r != ConnectivityResult.none)
          .map((r) => r.name)
          .toList();
      _connectivity = names.isEmpty ? 'Offline' : names.join(' + ');
    } catch (e) {
      _connectivity = 'Unknown';
    }
    try {
      final info = await PackageInfo.fromPlatform();
      _version = '${info.version} (${info.buildNumber})';
    } catch (_) {
      _version = null;
    }
    await _loadCounts();
  }

  Future<void> _loadCounts() async {
    final db = ref.read(dbProvider);
    final skus = await db.select(db.skus).get();
    final visits = await db.select(db.visits).get();
    if (!mounted) return;
    setState(() => _counts = (
          skus: skus.where((s) => s.isActive).length,
          enrolled: skus.where((s) => s.isActive && s.isEnrolled).length,
          visits: visits.length,
        ));
  }

  // ---- actions ----------------------------------------------------------

  Future<void> _run(String label, Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      AppLogger.e(_tag, '$label failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$label failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body, String verb) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppText.heading),
        content: Text(body, style: AppText.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(verb, style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _reloadDetector() => _run('Detector reload', () async {
        final d = ref.read(detectorProvider);
        if (d is TfliteDetector) {
          await d.close();
          await d.load();
        }
      });

  Future<void> _reloadRecogniser() => _run('Recogniser reload', () async {
        final e = ref.read(embedderProvider);
        if (e is TfliteEmbedder) {
          await e.close();
          await e.load();
        }
        await ref.read(skuIndexProvider).refresh();
      });

  Future<void> _resetDemoData() async {
    if (!await _confirm(
      'Reset demo data?',
      'Deletes every visit, photo, detection, shelf fact, order line, '
          'override and export batch. Keeps the SKU catalogue, enrolment shots '
          'and embeddings, planogram, beats and stores.',
      'Reset',
    )) {
      return;
    }
    await _run('Reset', () async {
      await ref.read(dbProvider).resetForDemo();
      final docs = await getApplicationDocumentsDirectory();
      for (final name in ['photos', 'exports', 'crops']) {
        final dir = Directory(p.join(docs.path, name));
        if (await dir.exists()) await dir.delete(recursive: true);
      }
      AppLogger.i(_tag, 'Demo data reset');
      await _loadCounts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demo data reset. Beat is clean.')));
      }
    });
  }

  Future<void> _exportEnrolmentShots() => _run('Export shots', () async {
        final docs = await getApplicationDocumentsDirectory();
        final enrol = Directory(p.join(docs.path, 'enrol'));
        if (!await enrol.exists()) {
          throw StateError('No enrolment shots yet');
        }
        final tmp = await getTemporaryDirectory();
        final zipPath = p.join(tmp.path,
            'enrol_${DateTime.now().millisecondsSinceEpoch}.zip');
        // Folders are SKU ids; the catalogue maps them to codes.
        await ZipFileEncoder().zipDirectory(enrol, filename: zipPath);
        final db = ref.read(dbProvider);
        final skus = await db.select(db.skus).get();
        final map = skus.map((s) => '${s.id},${s.code},${s.name}').join('\n');
        final mapPath = p.join(tmp.path, 'sku_map.csv');
        await File(mapPath).writeAsString('sku_id,code,name\n$map\n');
        await SharePlus.instance.share(ShareParams(
          files: [
            XFile(zipPath, mimeType: 'application/zip'),
            XFile(mapPath, mimeType: 'text/csv'),
          ],
          text: 'ShelfSense enrolment shots',
        ));
      });

  Future<void> _dumpLogs() => _run('Dump logs', () async {
        final tmp = await getTemporaryDirectory();
        final path = p.join(tmp.path,
            'shelfsense_log_${DateTime.now().millisecondsSinceEpoch}.txt');
        await File(path).writeAsString(AppLogger.dumpText());
        await SharePlus.instance.share(ShareParams(
          files: [XFile(path, mimeType: 'text/plain')],
          text: 'ShelfSense log',
        ));
      });

  // ---- build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(thresholdsProvider);
    final detector = ref.watch(detectorProvider);
    final embedder = ref.watch(embedderProvider);
    final index = ref.watch(skuIndexProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(Sp.screen),
        children: [
          const _SectionLabel('Models'),
          if (detector is TfliteDetector)
            _ModelCard(
              title: 'Pack finder',
              loaded: detector.isLoaded,
              rows: [
                ('Asset', _basename(detector.loadedAsset)),
                ('Delegate', detector.info?.delegate ?? '–'),
                ('Load', _ms(detector.info?.loadMs)),
                ('Mean latency', _ms(detector.meanLatencyMs)),
                if (detector.info != null)
                  ('Input', '${detector.info!.inputSize} px'),
              ],
              onReload: _busy ? null : _reloadDetector,
            ),
          const SizedBox(height: Sp.sm),
          if (embedder is TfliteEmbedder)
            _ModelCard(
              title: 'Recogniser',
              loaded: embedder.isLoaded,
              rows: [
                ('Asset', _basename(embedder.loadedAsset)),
                ('Delegate', embedder.info?.delegate ?? '–'),
                ('Load', _ms(embedder.info?.loadMs)),
                ('Mean latency', _ms(embedder.meanLatencyMs)),
                ('Index', '${index.skuCount} SKUs'),
              ],
              onReload: _busy ? null : _reloadRecogniser,
            ),
          const SizedBox(height: Sp.xl),
          const _SectionLabel('Thresholds'),
          _Card(
            child: Column(
              children: [
                _ThresholdSlider(
                  label: 'Detector confidence',
                  value: t.detConf,
                  min: 0.05,
                  max: 0.95,
                  onChanged: t.setDetConf,
                ),
                _ThresholdSlider(
                  label: 'NMS IoU',
                  value: t.detNmsIou,
                  min: 0.1,
                  max: 0.9,
                  onChanged: t.setDetNmsIou,
                ),
                _ThresholdSlider(
                  label: 'Match accept',
                  value: t.matchHigh,
                  min: 0,
                  max: 1,
                  onChanged: t.setMatchHigh,
                ),
                _ThresholdSlider(
                  label: 'Match reject below',
                  value: t.matchLow,
                  min: 0,
                  max: 1,
                  onChanged: t.setMatchLow,
                ),
                const SizedBox(height: Sp.sm),
                OutlinedButton(
                  onPressed: _busy ? null : () => t.resetToDefaults(),
                  child: const Text('Reset to defaults'),
                ),
                const SizedBox(height: Sp.xs),
                Text(
                  'Takes effect on the next shutter press. Saved on the phone.',
                  style: AppText.label,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.xl),
          const _SectionLabel('Connectivity'),
          _Card(
            child: Row(
              children: [
                Icon(
                  _connectivity == 'Offline'
                      ? Icons.cloud_off
                      : Icons.wifi,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: Sp.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_connectivity ?? 'Checking…',
                          style: AppText.display),
                      const SizedBox(height: Sp.xs),
                      Text(
                        'The app never uses the network in the core path. '
                        'Capture, recognition, diff, order and export all run '
                        'on this handset.',
                        style: AppText.label,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.xl),
          const _SectionLabel('Danger zone'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _exportEnrolmentShots,
                  icon: const Icon(Icons.folder_zip_outlined),
                  label: const Text('Export enrolment shots'),
                ),
                const SizedBox(height: Sp.sm),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _dumpLogs,
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Dump logs'),
                ),
                const SizedBox(height: Sp.sm),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger),
                  ),
                  onPressed: _busy ? null : _resetDemoData,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Reset demo data'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.xl),
          const _SectionLabel('Appearance'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Follow the phone, or force light or dark.',
                    style: AppText.label),
                const SizedBox(height: Sp.md),
                SegmentedButton<ThemeMode>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.primary,
                    selectedForegroundColor: AppColors.onPrimary,
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                  ),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('Auto')),
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Light')),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Dark')),
                  ],
                  selected: {ref.watch(themeModeProvider)},
                  onSelectionChanged: (s) =>
                      ref.read(themeModeProvider.notifier).set(s.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.xl),
          const _SectionLabel('About'),
          _Card(
            child: Column(
              children: [
                _KV('Version', _version ?? '–'),
                _KV('SKUs', _counts == null ? '–' : '${_counts!.skus}'),
                _KV('Enrolled SKUs',
                    _counts == null ? '–' : '${_counts!.enrolled}'),
                _KV('Visits', _counts == null ? '–' : '${_counts!.visits}'),
              ],
            ),
          ),
          const SizedBox(height: Sp.xxl),
        ],
      ),
    );
  }

  static String _basename(String? path) =>
      path == null ? 'not bundled' : p.basename(path);

  static String _ms(int? v) => v == null || v == 0 ? '–' : '$v ms';
}

// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: Text(text.toUpperCase(),
          style: AppText.label.copyWith(letterSpacing: 0.8)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: child,
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.title,
    required this.loaded,
    required this.rows,
    required this.onReload,
  });
  final String title;
  final bool loaded;
  final List<(String, String)> rows;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final color = loaded ? AppColors.success : AppColors.textDisabled;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppText.heading)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Text(
                  loaded ? 'Loaded' : 'Not loaded',
                  style: AppText.label
                      .copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.sm),
          for (final (k, v) in rows) _KV(k, v),
          const SizedBox(height: Sp.sm),
          OutlinedButton(onPressed: onReload, child: const Text('Reload')),
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV(this.k, this.v);
  final String k, v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.xs),
      child: Row(
        children: [
          Expanded(child: Text(k, style: AppText.body)),
          Text(v, style: AppText.mono),
        ],
      ),
    );
  }
}

class _ThresholdSlider extends StatelessWidget {
  const _ThresholdSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final double value, min, max;
  final Future<void> Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppText.body)),
            Text(value.toStringAsFixed(2),
                style: AppText.mono.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) * 100).round(),
          onChanged: (v) => onChanged(v),
        ),
      ],
    );
  }
}

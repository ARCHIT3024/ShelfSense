import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
// `qr` is pulled in transitively by `printing`; no direct pubspec entry by design.
// ignore: depend_on_referenced_packages
import 'package:qr/qr.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme.dart';
import '../../core/logger.dart';
import 'handover_server.dart';

const _tag = 'HandoverScreen';

/// `/handover` — per-file Share rows plus the optional Wi-Fi server with a
/// QR code the laptop scans (04_UIUX §`/handover`).
class HandoverScreen extends StatefulWidget {
  const HandoverScreen({super.key});

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  final _server = HandoverServer();
  List<HandoverFile> _files = const [];
  bool _loading = true;
  bool _serving = false;
  String? _url;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    // Never leave a socket open after the rep walks away from this screen.
    _server.stop();
    super.dispose();
  }

  Future<void> _refresh() async {
    final files = await HandoverServer.listExports();
    if (!mounted) return;
    setState(() {
      _files = files;
      _loading = false;
    });
  }

  Future<void> _toggle(bool on) async {
    try {
      if (on) {
        await _server.start();
        final url = await _server.url();
        if (!mounted) return;
        setState(() {
          _serving = true;
          _url = url;
        });
      } else {
        await _server.stop();
        if (!mounted) return;
        setState(() {
          _serving = false;
          _url = null;
        });
      }
    } catch (e) {
      AppLogger.e(_tag, 'Server toggle failed', e);
      if (mounted) {
        setState(() => _serving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not start the server: $e')));
      }
    }
  }

  Future<void> _share(HandoverFile f) async {
    final dir = await HandoverServer.exportsDir();
    await SharePlus.instance.share(ShareParams(
      files: [XFile(p.join(dir.path, f.name))],
      text: f.name,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Handover')),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(Sp.screen),
              children: [
                _ServeCard(
                  serving: _serving,
                  url: _url,
                  onChanged: _toggle,
                ),
                const SizedBox(height: Sp.lg),
                Text('Files', style: AppText.heading),
                const SizedBox(height: Sp.xs),
                Text(
                  _files.isEmpty
                      ? 'No exports yet. Confirm an order first.'
                      : '${_files.length} file${_files.length == 1 ? '' : 's'} on the phone',
                  style: AppText.label,
                ),
                const SizedBox(height: Sp.sm),
                for (final f in _files) _FileRow(file: f, onShare: () => _share(f)),
              ],
            ),
    );
  }
}

class _ServeCard extends StatelessWidget {
  const _ServeCard({
    required this.serving,
    required this.url,
    required this.onChanged,
  });
  final bool serving;
  final String? url;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Serve on Wi-Fi', style: AppText.heading),
                    SizedBox(height: Sp.xs),
                    Text(
                      'The laptop downloads from the phone over the shared '
                      'hotspot. Nothing leaves the local network.',
                      style: AppText.label,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Sp.md),
              Switch(
                value: serving,
                activeThumbColor: AppColors.primary,
                onChanged: onChanged,
              ),
            ],
          ),
          if (serving) ...[
            const SizedBox(height: Sp.lg),
            if (url == null)
              Text(
                'Server is up but no Wi-Fi address was found. Join the '
                'hotspot and toggle again.',
                style: AppText.body,
              )
            else ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(Sp.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Radii.card),
                  ),
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: _QrView(data: url!),
                  ),
                ),
              ),
              const SizedBox(height: Sp.md),
              SelectableText(
                url!,
                textAlign: TextAlign.center,
                style: AppText.mono.copyWith(fontSize: 18),
              ),
              const SizedBox(height: Sp.xs),
              Text(
                'Scan or type this on the laptop, on the same hotspot.',
                textAlign: TextAlign.center,
                style: AppText.label,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file, required this.onShare});
  final HandoverFile file;
  final VoidCallback onShare;

  IconData get _icon => switch (p.extension(file.name).toLowerCase()) {
        '.xlsx' => Icons.table_chart_outlined,
        '.csv' => Icons.description_outlined,
        '.pdf' => Icons.picture_as_pdf_outlined,
        _ => Icons.insert_drive_file_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Sp.sm),
      padding: const EdgeInsets.fromLTRB(Sp.md, Sp.sm, Sp.xs, Sp.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Row(
        children: [
          Icon(_icon, color: AppColors.textSecondary),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name,
                    style: AppText.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(file.sizeLabel, style: AppText.label),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: onShare,
            icon: Icon(Icons.ios_share, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

/// QR from the `qr` package drawn with a CustomPainter — no extra dependency.
class _QrView extends StatelessWidget {
  const _QrView({required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    final code = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    return CustomPaint(painter: _QrPainter(QrImage(code)));
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter(this.image);
  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final n = image.moduleCount;
    final cell = size.shortestSide / n;
    final paint = Paint()..color = Colors.black;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (image.isDark(r, c)) {
          canvas.drawRect(
            Rect.fromLTWH(c * cell, r * cell, cell + 0.5, cell + 0.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.image != image;
}

/// T-30 — local HTTP handover server.
///
/// The phone is the backend; the laptop pulls the exported files over the
/// shared hotspot / Wi-Fi. This is the ONE sanctioned network feature in the
/// app (00_START_HERE non-negotiable #1 flags the local server as the
/// designed exception). It is off by default, only runs while the rep keeps
/// the toggle on `/handover` enabled, and never makes an outbound call.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../core/logger.dart';

const _tag = 'HandoverServer';

/// Preferred port; falls back to an ephemeral one if it is taken.
const kHandoverPort = 8080;

/// One servable export, as shown on the index page.
class HandoverFile {
  const HandoverFile({required this.name, required this.bytes});
  final String name;
  final int bytes;

  String get sizeLabel => formatBytes(bytes);
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Picks the address the laptop can reach: first non-loopback IPv4, preferring
/// a `wlan*` / `ap*` (hotspot) interface. Pure so it is unit-testable.
String? pickWifiIPv4(Iterable<NetworkInterface> interfaces) {
  String? fallback;
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (addr.type != InternetAddressType.IPv4 || addr.isLoopback) continue;
      final n = iface.name.toLowerCase();
      if (n.startsWith('wlan') || n.startsWith('ap') || n.startsWith('swlan')) {
        return addr.address;
      }
      fallback ??= addr.address;
    }
  }
  return fallback;
}

/// Minimal, dependency-free index page. Pure so it is unit-testable.
String buildIndexHtml(List<HandoverFile> files, {String title = 'ShelfSense'}) {
  final rows = files.isEmpty
      ? '<p class="muted">No exports yet. Confirm an order on the phone first.</p>'
      : files.map((f) {
          final href = '/files/${Uri.encodeComponent(f.name)}';
          return '<li><a href="$href" download>${_esc(f.name)}</a>'
              '<span class="muted">${f.sizeLabel}</span></li>';
        }).join();
  return '''<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>$title · handover</title>
<style>
body{font-family:system-ui,sans-serif;background:#0E1013;color:#F2F4F7;margin:0;padding:24px}
h1{font-size:20px;margin:0 0 4px}.muted{color:#98A2B3;font-size:13px}
ul{list-style:none;padding:0;margin:16px 0}li{display:flex;justify-content:space-between;
gap:16px;padding:12px 0;border-bottom:1px solid #2A3039}a{color:#FF6B2C;text-decoration:none;word-break:break-all}
</style></head><body>
<h1>$title</h1><p class="muted">${files.length} file${files.length == 1 ? '' : 's'} · served from the phone, offline</p>
<ul>$rows</ul>
</body></html>''';
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// Serves the app's `exports/` directory. One instance per screen; call
/// [stop] on dispose so nothing keeps listening after the rep leaves.
class HandoverServer {
  HttpServer? _server;
  Directory? _dir;

  bool get isRunning => _server != null;
  int? get port => _server?.port;

  /// `http://<wifi-ip>:<port>/`, or null while stopped / without Wi-Fi.
  Future<String?> url() async {
    final s = _server;
    if (s == null) return null;
    final ip = pickWifiIPv4(await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    ));
    return ip == null ? null : 'http://$ip:${s.port}/';
  }

  static Future<Directory> exportsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'exports'));
    await dir.create(recursive: true);
    return dir;
  }

  static Future<List<HandoverFile>> listExports() async {
    final dir = await exportsDir();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => !p.basename(f.path).startsWith('.'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return [
      for (final f in files)
        HandoverFile(name: p.basename(f.path), bytes: f.lengthSync()),
    ];
  }

  Future<void> start() async {
    if (_server != null) return;
    _dir = await exportsDir();
    final handler = const shelf.Pipeline().addHandler(_handle);
    try {
      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, kHandoverPort);
    } on SocketException {
      // Port taken — let the OS pick one.
      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
    }
    AppLogger.i(_tag, 'Serving ${_dir!.path} on port ${_server!.port}');
  }

  Future<void> stop() async {
    final s = _server;
    _server = null;
    if (s != null) {
      await s.close(force: true);
      AppLogger.i(_tag, 'Stopped');
    }
  }

  Future<shelf.Response> _handle(shelf.Request req) async {
    final segments = req.url.pathSegments;
    if (segments.isEmpty) {
      return shelf.Response.ok(
        buildIndexHtml(await listExports()),
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    }
    if (segments.length == 2 && segments.first == 'files') {
      final name = p.basename(segments[1]); // no traversal
      final file = File(p.join(_dir!.path, name));
      if (!await file.exists()) return shelf.Response.notFound('No such file');
      return shelf.Response.ok(
        file.openRead(),
        headers: {
          'content-type': _mime(name),
          'content-length': '${await file.length()}',
          'content-disposition': 'attachment; filename="$name"',
        },
      );
    }
    return shelf.Response.notFound('Not found');
  }

  static String _mime(String name) {
    final ext = p.extension(name).toLowerCase();
    return switch (ext) {
      '.xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      '.csv' => 'text/csv',
      '.pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };
  }
}

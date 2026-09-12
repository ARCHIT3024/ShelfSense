import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelfsense/features/handover/handover_server.dart';

void main() {
  group('buildIndexHtml', () {
    test('lists files with encoded download links and sizes', () {
      final html = buildIndexHtml(const [
        HandoverFile(name: 'order KIR-0101.xlsx', bytes: 15 * 1024),
        HandoverFile(name: 'beat.pdf', bytes: 2 * 1024 * 1024),
      ]);
      expect(html, contains('href="/files/order%20KIR-0101.xlsx"'));
      expect(html, contains('15.0 KB'));
      expect(html, contains('2.0 MB'));
      expect(html, contains('2 files'));
    });

    test('escapes html in file names', () {
      final html =
          buildIndexHtml(const [HandoverFile(name: 'a<b>.csv', bytes: 1)]);
      expect(html, contains('a&lt;b&gt;.csv'));
      expect(html, isNot(contains('a<b>.csv</a>')));
    });

    test('empty state has no list items', () {
      final html = buildIndexHtml(const []);
      expect(html, contains('No exports yet'));
      expect(html, isNot(contains('<li>')));
    });
  });

  group('formatBytes', () {
    test('picks the unit', () {
      expect(formatBytes(512), '512 B');
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(3 * 1024 * 1024), '3.0 MB');
    });
  });

  group('pickWifiIPv4', () {
    test('never returns loopback and returns dotted IPv4 when present',
        () async {
      final ifaces = await NetworkInterface.list(
          includeLoopback: false, type: InternetAddressType.IPv4);
      final ip = pickWifiIPv4(ifaces);
      if (ip != null) {
        expect(ip, isNot(startsWith('127.')));
        expect(ip.split('.'), hasLength(4));
      }
    });
  });
}

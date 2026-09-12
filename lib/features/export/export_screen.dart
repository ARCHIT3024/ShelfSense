import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/result.dart';
import '../../output/csv_builder.dart';
import '../../output/xlsx_builder.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _status;
  bool _busy = false;

  Future<void> _runSmokeTest() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    final xlsx = await writeHelloWorldXlsx();
    final csv = await buildOrderCsv(storeCode: 'DEMO-001', lines: const []);
    setState(() {
      _busy = false;
      _status = switch ((xlsx, csv)) {
        (Ok(value: final xPath), Ok(value: final cPath)) =>
          'XLSX: $xPath\nCSV: $cPath\n\nOpen the XLSX and check for a '
              'Syncfusion trial watermark (T-08 exit criterion).',
        _ => 'XLSX: ${xlsx.failureOrNull ?? 'ok'}\n'
            'CSV: ${csv.failureOrNull ?? 'ok'}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Beat')),
      body: Padding(
        padding: const EdgeInsets.all(Sp.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Full beat export (T-19 / T-30: XLSX + CSV + PDF + local HTTP '
              'handover) is not wired up yet. Use the button below to smoke-'
              'test the on-device XLSX/CSV writers (T-08).',
              style: AppText.body,
            ),
            const SizedBox(height: Sp.md),
            FilledButton(
              onPressed: _busy ? null : _runSmokeTest,
              child: Text(_busy ? 'Writing…' : 'Write test XLSX + CSV'),
            ),
            if (_status != null) ...[
              const SizedBox(height: Sp.md),
              Text(_status!, style: AppText.body),
            ],
          ],
        ),
      ),
    );
  }
}

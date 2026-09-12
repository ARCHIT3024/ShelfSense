import 'package:flutter/material.dart';
import '../../app/theme.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: Center(
        child: Text('Model status · thresholds · logs (T-30 polish)',
            style: AppText.body, textAlign: TextAlign.center),
      ),
    );
  }
}

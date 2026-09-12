import 'package:flutter/material.dart';
import '../../app/theme.dart';

class BenchmarkScreen extends StatelessWidget {
  const BenchmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benchmark')),
      body: Center(
        child: Text('On-device vs cloud benchmark (L3)',
            style: AppText.body, textAlign: TextAlign.center),
      ),
    );
  }
}

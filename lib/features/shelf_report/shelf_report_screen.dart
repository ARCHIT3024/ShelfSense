import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class ShelfReportScreen extends StatelessWidget {
  const ShelfReportScreen({super.key, required this.visitId});
  final String visitId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shelf Status')),
      body: Center(
        child: Text('Shelf — visitId: $visitId\n(T-18: planogram diff next)',
            style: AppText.body, textAlign: TextAlign.center),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.sm, Sp.screen, Sp.lg),
          child: FilledButton(
            onPressed: () => context.go('/order/$visitId'),
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

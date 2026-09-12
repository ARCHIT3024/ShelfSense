import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key, required this.visitId});
  final String visitId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Detections')),
      body: Center(
        child: Text('Review — visitId: $visitId\n(T-15: Full UI next)',
            style: AppText.body, textAlign: TextAlign.center),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.sm, Sp.screen, Sp.lg),
          child: FilledButton(
            onPressed: () => context.go('/shelf/$visitId'),
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

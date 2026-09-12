import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key, required this.visitId});
  final String visitId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Draft')),
      body: Center(
        child: Text('Order — visitId: $visitId\n(T-19: steppers + XLSX next)',
            style: AppText.body, textAlign: TextAlign.center),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sp.screen, Sp.sm, Sp.screen, Sp.lg),
          child: FilledButton(
            onPressed: () => context.go('/beat'),
            child: const Text('Confirm Visit'),
          ),
        ),
      ),
    );
  }
}

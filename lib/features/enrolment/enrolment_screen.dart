import 'package:flutter/material.dart';
import '../../app/theme.dart';

class EnrolmentScreen extends StatelessWidget {
  const EnrolmentScreen({super.key, this.skuId, this.preloadedCropPath});
  final String? skuId;
  final String? preloadedCropPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrol SKU')),
      body: Center(
        child: Text('Enrolment (T-22: 3-step flow next)',
            style: AppText.body, textAlign: TextAlign.center),
      ),
    );
  }
}

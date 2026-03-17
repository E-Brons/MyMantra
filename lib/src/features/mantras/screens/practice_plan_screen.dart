import 'package:flutter/material.dart';

/// Practice Plan (screen 3) — stub for Wave 6 implementation.
class PracticePlanScreen extends StatelessWidget {
  final String mantraId;
  final bool editMode;
  const PracticePlanScreen({super.key, required this.mantraId, this.editMode = false});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Practice Plan')),
    );
  }
}

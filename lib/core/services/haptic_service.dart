import 'package:flutter/services.dart';

class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  Future<void> light() => HapticFeedback.lightImpact();
  Future<void> medium() => HapticFeedback.mediumImpact();
  Future<void> heavy() => HapticFeedback.heavyImpact();
  Future<void> selection() => HapticFeedback.selectionClick();
}

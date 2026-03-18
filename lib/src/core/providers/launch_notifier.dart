import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// Tracks whether the user has completed onboarding.
///
/// [isLoading] is true until the storage check completes.
/// The router waits on this before deciding whether to show /welcome.
class LaunchNotifier extends ChangeNotifier {
  bool? _hasLaunched; // null = async check in progress

  bool get isLoading => _hasLaunched == null;
  bool get hasLaunched => _hasLaunched ?? false;

  LaunchNotifier() {
    _init();
  }

  Future<void> _init() async {
    _hasLaunched = await StorageService.instance.hasLaunched();
    notifyListeners();
  }

  Future<void> markLaunched() async {
    await StorageService.instance.markLaunched();
    _hasLaunched = true;
    notifyListeners();
  }
}

final launchNotifier = LaunchNotifier();

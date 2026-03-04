import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mantra.dart';
import '../models/session.dart';
import '../models/progress.dart';
import '../models/settings.dart';

const _kStateKey = 'mymantra_state';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStateKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required List<Mantra> mantras,
    required List<Session> sessions,
    required Progress progress,
    required Settings settings,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'mantras': mantras.map((m) => m.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'progress': progress.toJson(),
      'settings': settings.toJson(),
    };
    await prefs.setString(_kStateKey, jsonEncode(data));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app/app.dart';
import 'src/core/services/icon_registry.dart';
import 'src/core/services/theme_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    IconRegistry.instance.init(),
    ThemeRegistry.instance.init(),
  ]);
  runApp(const ProviderScope(child: MyMantraApp()));
}

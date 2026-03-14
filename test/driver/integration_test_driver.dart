import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

/// Host-side driver for emoji screenshot integration tests.
/// Invoked by `flutter drive --driver=test/driver/integration_test_driver.dart`
/// Screenshots are received here (on the host), saved to tmp/, and validated via Python OCR.
Future<void> main() => integrationDriver(
      onScreenshot: (
        String screenshotName,
        List<int> screenshotBytes, [
        Map<String, Object?>? args,
      ]) async {
        final outputDir = Directory('tmp');
        if (!outputDir.existsSync()) {
          outputDir.createSync(recursive: true);
        }

        final file = File('tmp/$screenshotName.png');
        await file.writeAsBytes(screenshotBytes);
        print('[driver] Screenshot saved: ${file.path}');

        final venvPython = File('.venv/bin/python');
        final pythonExec = venvPython.existsSync() ? venvPython.path : 'python3';

        final result = await Process.run(pythonExec, [
          'test/driver/emoji_screenshots_test.py',
          screenshotName,
          file.path,
        ]);

        print(result.stdout);
        if (result.stderr != null && (result.stderr as String).isNotEmpty) {
          print('[driver] stderr: ${result.stderr}');
        }

        if (result.exitCode != 0) {
          print('[driver] ❌ Emoji check FAILED for $screenshotName');
          return false;
        }

        print('[driver] ✅ Emoji check PASSED for $screenshotName');
        return true;
      },
    );

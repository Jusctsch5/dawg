import 'dart:convert';
import 'dart:io';

import 'package:dawg/workout/tts/platform_speech.dart';

/// Windows desktop TTS via PowerShell System.Speech (SAPI).
/// Avoids flutter_tts, whose native plugin fails to compile with current MSVC.
class WindowsSapiTts implements PlatformSpeech {
  Process? _current;
  File? _currentTempFile;

  @override
  Future<void> speak(String text) async {
    await _stop();
    if (text.isEmpty) return;

    final tempPath =
        '${Directory.systemTemp.path}\\dawg_tts_${DateTime.now().microsecondsSinceEpoch}.txt';
    final tempFile = File(tempPath);
    await tempFile.writeAsString(text, encoding: utf8, flush: true);

    const script = r'''
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$content = Get-Content -Raw -LiteralPath $env:DAWG_TTS_FILE
$synth.Speak($content)
''';

    final process = await Process.start(
      'powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ],
      environment: {'DAWG_TTS_FILE': tempPath},
    );

    _current = process;
    _currentTempFile = tempFile;

    try {
      await process.exitCode;
    } finally {
      try {
        await tempFile.delete();
      } catch (_) {}
      if (identical(_current, process)) {
        _current = null;
        _currentTempFile = null;
      }
    }
  }

  Future<void> _stop() async {
    final process = _current;
    final temp = _currentTempFile;
    _current = null;
    _currentTempFile = null;
    if (process != null) {
      process.kill();
      try {
        await process.exitCode;
      } catch (_) {}
    }
    if (temp != null) {
      try {
        await temp.delete();
      } catch (_) {}
    }
  }
}

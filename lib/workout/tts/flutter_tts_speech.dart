import 'package:dawg/workout/tts/platform_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Cross-platform TTS via [flutter_tts] (Android, iOS, macOS, Web, Windows).
class FlutterTtsSpeech implements PlatformSpeech {
  FlutterTtsSpeech() {
    _tts = FlutterTts();
    _tts.awaitSpeakCompletion(true);
  }

  late final FlutterTts _tts;

  @override
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    // Do NOT call stop() before the first utterance on Windows. flutter_tts 4.2.5
    // WinRT backend (WINAPI_FAMILY_DESKTOP_APP) null-dereferences speakResult in
    // stop() when awaitSpeakCompletion is true but no speak() has run yet.
    await _tts.speak(text);
  }
}

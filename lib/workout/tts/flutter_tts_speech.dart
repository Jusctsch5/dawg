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
    await _tts.stop();
    await _tts.speak(text);
  }
}

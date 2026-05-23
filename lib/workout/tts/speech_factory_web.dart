import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:dawg/workout/tts/platform_speech.dart';

PlatformSpeech createPlatformSpeech() => _WebSpeech();

class _WebSpeech implements PlatformSpeech {
  @override
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    final synthesis = html.window.speechSynthesis;
    if (synthesis == null) return;

    final completer = Completer<void>();
    final utterance = html.SpeechSynthesisUtterance(text);
    utterance.onEnd.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
    utterance.onError.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
    synthesis.speak(utterance);
    await completer.future;
  }
}

// ignore_for_file: avoid_print

import 'package:dawg/workout/tts/speech_factory.dart';

abstract class Announcer {
  Future announce(String text);
  Future announceDelay(int secs);
  Future announceCountdown(int from);
}

class AnnouncerTts extends Announcer {
  AnnouncerTts() : _speech = createPlatformSpeech();

  final PlatformSpeech _speech;

  @override
  Future announce(String text) async {
    await _speech.speak(text);
  }

  @override
  Future announceDelay(int secs) async {
    await Future.delayed(Duration(seconds: secs));
  }

  @override
  Future announceCountdown(int from) async {
    for (; from > 0; from--) {
      await _speech.speak(from.toString());
    }
  }
}

class AnnouncerLog extends Announcer {
  AnnouncerLog();

  @override
  Future announce(String text) async {
    print(text);
  }

  @override
  Future announceDelay(int secs) async {
    print("Delaying $secs seconds");
  }

  @override
  Future announceCountdown(int from) async {
    String countdown = "";
    for (; from > 0; from--) {
      countdown += "$from ";
    }
    print(countdown);
  }
}

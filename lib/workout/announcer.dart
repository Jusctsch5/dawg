// ignore_for_file: avoid_print

import 'package:flutter_tts/flutter_tts.dart';

abstract class Announcer
{

  Future announce(String text);
  Future announceDelay(int secs);
  Future announceCountdown(int from);
}

class AnnouncerTts extends Announcer {
  FlutterTts flutterTts;

  AnnouncerTts() :
    flutterTts = FlutterTts();

  @override
  Future announce(String text) async {
      await flutterTts.speak(text);
      await flutterTts.awaitSpeakCompletion(true);
  }

  @override
  Future announceDelay(int secs) async {
      await Future.delayed(Duration(seconds: secs));
  }

  @override
  Future announceCountdown(int from) async {
    for (; from > 0; from--) {
      await flutterTts.speak(from.toString());
      await flutterTts.awaitSpeakCompletion(true); // waits about a second inbetween
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
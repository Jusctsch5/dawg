// ignore_for_file: avoid_print

import 'package:dawg/workout/announcer_sentence_split.dart';
import 'package:dawg/workout/tts/speech_factory.dart';
import 'package:dawg/workout/workout_playback_gate.dart';

abstract class Announcer {
  WorkoutPlaybackGate get gate;

  /// Speaks [text], split on `.` into sentence chunks. Returns false if cancelled.
  Future<bool> announce(String text);

  /// Waits [secs] seconds, honouring cancel/pause. Returns false if cancelled.
  Future<bool> announceDelay(int secs);

  /// Speaks a countdown from [from] down to 1. Returns false if cancelled.
  Future<bool> announceCountdown(int from);

  Future<bool> _announceChunks(String text, Future<void> Function(String chunk) speak) async {
    final chunks = splitAnnouncerSentences(text);
    if (chunks.isEmpty) return true;

    for (final chunk in chunks) {
      if (!await gate.proceed()) return false;
      await speak(chunk);
      if (!await gate.proceed()) return false;
    }
    return true;
  }

  Future<bool> _announceDelayLoop(int secs) async {
    for (var i = 0; i < secs; i++) {
      if (!await gate.proceed()) return false;
      await Future.delayed(const Duration(seconds: 1));
    }
    return true;
  }

  Future<bool> _announceCountdownLoop(int from, Future<void> Function(String chunk) speak) async {
    for (var n = from; n > 0; n--) {
      if (!await gate.proceed()) return false;
      await speak('$n');
      if (!await gate.proceed()) return false;
    }
    return true;
  }
}

class AnnouncerTts extends Announcer {
  AnnouncerTts({WorkoutPlaybackGate? gate})
      : _gate = gate ?? WorkoutPlaybackGate(),
        _speech = createPlatformSpeech();

  final WorkoutPlaybackGate _gate;
  final PlatformSpeech _speech;

  @override
  WorkoutPlaybackGate get gate => _gate;

  @override
  Future<bool> announce(String text) => _announceChunks(text, _speech.speak);

  @override
  Future<bool> announceDelay(int secs) => _announceDelayLoop(secs);

  @override
  Future<bool> announceCountdown(int from) => _announceCountdownLoop(from, _speech.speak);
}

class AnnouncerLog extends Announcer {
  AnnouncerLog({WorkoutPlaybackGate? gate}) : _gate = gate ?? WorkoutPlaybackGate();

  final WorkoutPlaybackGate _gate;

  @override
  WorkoutPlaybackGate get gate => _gate;

  @override
  Future<bool> announce(String text) => _announceChunks(text, (chunk) async => print(chunk));

  @override
  Future<bool> announceDelay(int secs) async {
    print('Delaying $secs seconds');
    return _announceDelayLoop(secs);
  }

  @override
  Future<bool> announceCountdown(int from) => _announceCountdownLoop(from, (chunk) async => print(chunk));
}

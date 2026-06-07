import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/workout_playback_gate.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

Future<void> testAnnouncer() async {
  final gate = WorkoutPlaybackGate();
  final announcer = AnnouncerLog(gate: gate);

  expect(await announcer.announce('hello world wii'), isTrue);
  for (var i = 1; i <= 3; i++) {
    expect(await announcer.announce('hello world $i'), isTrue);
  }

  expect(await announcer.announce('test delay 2 seconds'), isTrue);
  expect(await announcer.announceDelay(2), isTrue);
  expect(await announcer.announce('delay done'), isTrue);

  expect(await announcer.announce('test countdown from 5'), isTrue);
  expect(await announcer.announceCountdown(5), isTrue);
  expect(await announcer.announce('countdown done'), isTrue);
}

void main() {
  group('Announcer', () {
    test('testAnnouncer', () async {
      WidgetsFlutterBinding.ensureInitialized();
      await testAnnouncer();
    });

    test('cancel before announce returns false', () async {
      final gate = WorkoutPlaybackGate();
      final announcer = AnnouncerLog(gate: gate);
      gate.cancel();
      expect(await announcer.announce('Alpha. Beta.'), isFalse);
    });

    test('cancel during multi-sentence announce returns false', () async {
      final gate = WorkoutPlaybackGate();
      final announcer = AnnouncerLog(gate: gate);
      final future = announcer.announce('One. Two. Three.');
      gate.cancel();
      expect(await future, isFalse);
    });
  });
}

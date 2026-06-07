import 'package:dawg/workout/announcer.dart';
import 'package:flutter/material.dart';

/// Manual smoke test: `flutter run lib/workout/test/tts_smoke_test.dart -d windows`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final announcer = AnnouncerTts();
  await announcer.announce('DAWG text to speech smoke test.');
  await announcer.announceCountdown(3);
  await announcer.announce('Done.');
}

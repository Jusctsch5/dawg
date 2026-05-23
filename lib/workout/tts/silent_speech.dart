import 'package:dawg/workout/tts/platform_speech.dart';

class SilentSpeech implements PlatformSpeech {
  @override
  Future<void> speak(String text) async {}
}

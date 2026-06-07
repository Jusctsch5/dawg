import 'dart:io';

import 'package:dawg/workout/tts/flutter_tts_speech.dart';
import 'package:dawg/workout/tts/platform_speech.dart';
import 'package:dawg/workout/tts/silent_speech.dart';

PlatformSpeech createPlatformSpeech() {
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows) {
    return FlutterTtsSpeech();
  }
  return SilentSpeech();
}

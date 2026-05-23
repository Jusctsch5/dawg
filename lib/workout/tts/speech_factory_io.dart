import 'dart:io';

import 'package:dawg/workout/tts/platform_speech.dart';
import 'package:dawg/workout/tts/silent_speech.dart';
import 'package:dawg/workout/tts/windows_sapi_tts.dart';

PlatformSpeech createPlatformSpeech() {
  if (Platform.isWindows) {
    return WindowsSapiTts();
  }
  return SilentSpeech();
}

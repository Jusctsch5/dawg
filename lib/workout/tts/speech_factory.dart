import 'package:dawg/workout/tts/platform_speech.dart';
import 'package:dawg/workout/tts/speech_factory_stub.dart'
    if (dart.library.html) 'package:dawg/workout/tts/speech_factory_web.dart'
    if (dart.library.io) 'package:dawg/workout/tts/speech_factory_io.dart'
    as speech_impl;

export 'package:dawg/workout/tts/platform_speech.dart';

PlatformSpeech createPlatformSpeech() => speech_impl.createPlatformSpeech();

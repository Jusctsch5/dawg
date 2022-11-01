import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

import 'package:dawg/configuration/workout_configuration.dart';
import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/workout/decoder.dart';
import 'dart:developer';

Future<void> testDecoder() async {
  var file = File('lib/configuration/test/workout_configuration.json');
  var json = jsonDecode(await file.readAsString());
  var woConfig = WorkoutConfiguration.fromJson(json);

  file = File('lib/configuration/test/exercise_configuration.json');
  json = jsonDecode(await file.readAsString());
  var exConfig = ExerciseConfiguration.fromJson(json);

  var decoder = Decoder();

  var workout = decoder.generateWorkout(woConfig, exConfig);
  inspect(workout);

}

void main() {
  group("Decoder", () {
    test("testDecoder", () async {
      await testDecoder();
    });
  });
}

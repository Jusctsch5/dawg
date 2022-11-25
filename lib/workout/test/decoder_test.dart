import 'package:dawg/common_defines.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

import 'package:dawg/configuration/workout_configuration.dart';
import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/workout/decoder.dart';
import 'dart:developer';

Future<void> testDecoder() async {
  Map<String, dynamic> json = {
    "name": "Dynamic Workout",
    "muscleGroups": ["arms", "legs", "abdominals"],
    "equipment": ["all"],
    "durationMinutes": 20,
    "startDelay": 20,
    "finishDelay": 60,
    "setDurationSeconds": 30,
    "setPerExercise": 3
  };
  var woConfig = WorkoutConfiguration.fromJson(json);

  var file = File('lib/configuration/test/exercise_configuration.json');
  json = jsonDecode(await file.readAsString());
  var exConfig = ExerciseConfiguration.fromJson(json);

  var decoder = Decoder();

  var workout = decoder.generateWorkout(woConfig, exConfig);
  inspect(workout);
}

Future<void> testDecoderArms() async {
  Map<String, dynamic> json = {
    "name": "Dynamic Workout",
    "muscleGroups": ["arms"],
    "equipment": ["all"],
    "durationMinutes": 20,
    "startDelay": 20,
    "finishDelay": 60,
    "setDurationSeconds": 30,
    "setPerExercise": 3
  };

  var woConfig = WorkoutConfiguration.fromJson(json);

  var file = File('lib/configuration/test/exercise_configuration.json');
  json = jsonDecode(await file.readAsString());
  var exConfig = ExerciseConfiguration.fromJson(json);

  var decoder = Decoder();

  var workout = decoder.generateWorkout(woConfig, exConfig);
  for (var exercise in workout.exercises) {
    expect(exercise.exercise.muscleGroups.contains(MuscleGroup.arms), true);
  }
}

void main() {
  group("Decoder", () {
    test("testDecoder", () async {
      await testDecoder();
    });
    test("testArms", () async {
      await testDecoderArms();
    });
  });
}

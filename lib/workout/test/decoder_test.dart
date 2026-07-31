import 'package:dawg/common_defines.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

import 'package:dawg/configuration/workout_configuration.dart';
import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/workout/decoder.dart';
import 'package:dawg/workout/workout_duration_estimator.dart';
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

  var file = File('assets/data/exercise/exercise_configuration.json');
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

  var file = File('assets/data/exercise/exercise_configuration.json');
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
    test('generated workout timed seconds stay near target', () async {
      final configJson = {
        'name': 'Dynamic Workout',
        'muscleGroups': ['arms', 'legs', 'abdominals'],
        'equipment': ['all'],
        'durationMinutes': 20,
        'startDelay': 30,
        'finishDelay': 60,
        'setDurationSeconds': 30,
        'setPerExercise': 3,
      };
      final woConfig = WorkoutConfiguration.fromJson(configJson);

      final file = File('assets/data/exercise/exercise_configuration.json');
      final exConfig = ExerciseConfiguration.fromJson(
        jsonDecode(await file.readAsString()),
      );

      final workout = Decoder().generateWorkout(woConfig, exConfig);
      final timedSeconds = WorkoutDurationEstimator.estimateTimedSeconds(workout);

      expect(woConfig.startDelaySeconds, 30);
      expect(woConfig.finishDelaySeconds, 60);
      expect(workout.exercises.length, lessThan(14));
      expect(timedSeconds, lessThanOrEqualTo(woConfig.durationSeconds));
      expect(workout.durationMinutes, WorkoutDurationEstimator.estimateMinutes(workout));
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:dawg/common_defines.dart';
import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/player.dart';
import 'package:dawg/workout/workout.dart';
import 'package:test/test.dart';
import 'package:flutter/material.dart';

import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/configuration/workout_configuration.dart';
import 'dart:developer';

import 'package:dawg/workout/exercisew.dart';

Future<void> testPlayer() async {
  var e1 = Exercise(name: "sweep", description: "Sweep up boogrit and clark", equipment: [Equipment.none], muscleGroups: [MuscleGroup.arms], muscles: [Muscle.glutes], alt: false);
  var e2 = Exercise(name: "beep", description: "Boogrit beeps", equipment: [Equipment.none], muscleGroups: [MuscleGroup.arms], muscles: [Muscle.glutes], alt: false);
  var e3 = Exercise(name: "jeep", description: "Clark turns into a jeep", equipment: [Equipment.none], muscleGroups: [MuscleGroup.arms], muscles: [Muscle.glutes], alt: false);

  var file = File('lib/configuration/test/workout_configuration.json');
  var json = jsonDecode(await file.readAsString());
  var workConfig = WorkoutConfiguration.fromJson(json);

  var ex1 = ExerciseW(e1, 10, 2);
  var ex2 = ExerciseW(e2, 10, 2);
  var ex3 = ExerciseW(e3, 10, 2);

  var workout = Workout("Example Workout", [ex1, ex2, ex3], workConfig.muscleGroups, workConfig.startDelaySeconds, workConfig.finishDelaySeconds, workConfig.durationMinutes);
  var player = Player();
  var announcer = AnnouncerTts();

  player.playWorkout(workout, announcer);
  inspect(workout);
}

void main() {
  group("Player", () {
    test("testPlayer", () async {
      WidgetsFlutterBinding.ensureInitialized();
      await testPlayer();
      await Future.delayed(const Duration(seconds: 5));
    });
  });
}

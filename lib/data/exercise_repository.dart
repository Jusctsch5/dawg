import 'dart:convert';

import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/configuration/workout_configuration.dart';
import 'package:flutter/services.dart';

class ExerciseRepository {
  ExerciseRepository._();

  static final ExerciseRepository instance = ExerciseRepository._();

  ExerciseConfiguration? _cache;

  Future<ExerciseConfiguration> loadExercises() async {
    if (_cache != null) {
      return _cache!;
    }

    final exConfigJson =
        jsonDecode(await rootBundle.loadString('assets/data/exercise/exercise_configuration.json'));
    _cache = ExerciseConfiguration.fromJson(exConfigJson);
    return _cache!;
  }

  Future<List<WorkoutConfiguration>> loadWorkoutConfigs() async {
    final configs = <WorkoutConfiguration>[];

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    final workoutPaths =
        manifestMap.keys.where((key) => key.contains('data/workout/')).toList()..sort();

    for (final workoutPath in workoutPaths) {
      final workoutJson = jsonDecode(await rootBundle.loadString(workoutPath));
      configs.add(WorkoutConfiguration.fromJson(workoutJson));
    }

    return configs;
  }
}

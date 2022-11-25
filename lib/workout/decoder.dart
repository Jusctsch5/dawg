import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/configuration/workout_configuration.dart';
import 'package:logger/logger.dart';

import '../common_defines.dart';
import 'exercisew.dart';
import 'workout.dart';

class Decoder {
  final log = Logger();

  /// Obtains a new exercise from list of exercises, where "new" means not present in excluded.
  /// If one is not available, return a random exercise.
  Exercise getNewExerciseFromListOrRandom(List<Exercise> exercises, List<Exercise> excluded) {
    exercises.shuffle();
    for (var exercise in exercises) {
      if (!excluded.contains(exercise)) {
        return exercise;
      }
    }
    return exercises[0];
  }

  Workout generateWorkout(WorkoutConfiguration woConfig, ExerciseConfiguration exConfig) {
    List<Exercise> exercisesForWorkout = [];
    List<ExerciseW> exercisesWForWorkout = [];
    var currentExerciseLengthSeconds = 0;

    var musclesToWork = getMusclesForGroups(woConfig.muscleGroups);
    musclesToWork.shuffle();

    // Find an exercise for each muscle to work.
    while (currentExerciseLengthSeconds < woConfig.durationSeconds) {
      for (var muscleToWork in musclesToWork) {
        var filter = ExerciseFilterByGroups(equipment: woConfig.equipment, muscle: muscleToWork);
        var muscleExercises = exConfig.filterExercisesByGroups(filter);
        var exerciseDef = getNewExerciseFromListOrRandom(muscleExercises, exercisesForWorkout);
        var exercisew = ExerciseW(exerciseDef, woConfig.setDurationSeconds, woConfig.setPerExercise);
        exercisesForWorkout.add(exerciseDef);
        exercisesWForWorkout.add(exercisew);
        currentExerciseLengthSeconds += exercisew.totalDuration;

        log.i("Adding exercise:${exerciseDef.name} to workout (musclegroup:${exerciseDef.muscleGroups}");
      }
    }

    // Plug in exercises until workout is complete.
    var filter = ExerciseFilterByGroups(equipment: woConfig.equipment, muscleGroups: woConfig.muscleGroups);
    var totalExercises = exConfig.filterExercisesByGroups(filter);
    while (currentExerciseLengthSeconds < woConfig.durationSeconds) {
      var exerciseDef = getNewExerciseFromListOrRandom(totalExercises, exercisesForWorkout);
      var exercisew = ExerciseW(exerciseDef, woConfig.setDurationSeconds, woConfig.setPerExercise);
      exercisesForWorkout.add(exerciseDef);
      exercisesWForWorkout.add(exercisew);
      currentExerciseLengthSeconds += exercisew.totalDuration;

      log.i("Adding exercise:${exerciseDef.name} to workout (musclegroup:${exerciseDef.muscleGroups}");
    }

    return Workout(woConfig.name, exercisesWForWorkout, woConfig.muscleGroups, woConfig.startDelaySeconds, woConfig.finishDelaySeconds,
        woConfig.durationMinutes);
  }
}

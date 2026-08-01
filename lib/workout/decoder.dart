import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/configuration/workout_configuration.dart';
import 'package:dawg/workout/workout_duration_estimator.dart';
import 'package:logger/logger.dart';

import '../common_defines.dart';
import 'exercisew.dart';
import 'workout.dart';

class Decoder {
  final log = Logger();

  /// Obtains a new exercise from list of exercises, where "new" means not present in excluded.
  /// Returns null if [exercises] is empty.
  Exercise? getNewExerciseFromListOrRandom(List<Exercise> exercises, List<Exercise> excluded) {
    if (exercises.isEmpty) return null;

    exercises.shuffle();
    for (var exercise in exercises) {
      if (!excluded.contains(exercise)) {
        return exercise;
      }
    }
    return exercises[0];
  }

  int _exerciseTimedSeconds(WorkoutConfiguration woConfig) {
    return WorkoutDurationEstimator.exerciseTimedSeconds(
      setDurationSeconds: woConfig.setDurationSeconds,
      sets: woConfig.setPerExercise,
      startDelaySeconds: woConfig.startDelaySeconds,
    );
  }

  Workout generateWorkout(WorkoutConfiguration woConfig, ExerciseConfiguration exConfig) {
    List<Exercise> exercisesForWorkout = [];
    List<ExerciseW> exercisesWForWorkout = [];
    var currentExerciseLengthSeconds = 0;
    final exerciseTimedSeconds = _exerciseTimedSeconds(woConfig);
    final exerciseBudgetSeconds = WorkoutDurationEstimator.exerciseBudgetSeconds(
      woConfig.durationSeconds,
      woConfig.finishDelaySeconds,
    );

    var musclesToWork = getMusclesForGroups(woConfig.muscleGroups);
    musclesToWork.shuffle();

    // Find an exercise for each muscle to work.
    while (currentExerciseLengthSeconds + exerciseTimedSeconds <= exerciseBudgetSeconds) {
      var addedThisPass = false;
      for (var muscleToWork in musclesToWork) {
        if (currentExerciseLengthSeconds + exerciseTimedSeconds > exerciseBudgetSeconds) {
          break;
        }

        var filter = ExerciseFilterByGroups(
          equipment: woConfig.equipment,
          muscleGroups: woConfig.muscleGroups,
          muscle: muscleToWork,
        );
        var muscleExercises = exConfig.filterExercisesByGroups(filter);
        var exerciseDef = getNewExerciseFromListOrRandom(muscleExercises, exercisesForWorkout);
        if (exerciseDef == null) {
          log.v('No ${woConfig.equipment} exercises for muscle $muscleToWork; skipping');
          continue;
        }

        var exercisew = ExerciseW(exerciseDef, woConfig.setDurationSeconds, woConfig.setPerExercise);
        exercisesForWorkout.add(exerciseDef);
        exercisesWForWorkout.add(exercisew);
        currentExerciseLengthSeconds += exerciseTimedSeconds;
        addedThisPass = true;

        log.i("Adding exercise:${exerciseDef.name} to workout (musclegroup:${exerciseDef.muscleGroups}");
      }
      // Avoid infinite loop when no muscle has matching equipment.
      if (!addedThisPass) break;
    }

    // Plug in exercises until workout is complete.
    var filter = ExerciseFilterByGroups(equipment: woConfig.equipment, muscleGroups: woConfig.muscleGroups);
    var totalExercises = exConfig.filterExercisesByGroups(filter);
    while (currentExerciseLengthSeconds + exerciseTimedSeconds <= exerciseBudgetSeconds) {
      var exerciseDef = getNewExerciseFromListOrRandom(totalExercises, exercisesForWorkout);
      if (exerciseDef == null) break;

      var exercisew = ExerciseW(exerciseDef, woConfig.setDurationSeconds, woConfig.setPerExercise);
      exercisesForWorkout.add(exerciseDef);
      exercisesWForWorkout.add(exercisew);
      currentExerciseLengthSeconds += exerciseTimedSeconds;

      log.i("Adding exercise:${exerciseDef.name} to workout (musclegroup:${exerciseDef.muscleGroups}");
    }

    if (exercisesWForWorkout.isEmpty) {
      throw StateError(
        'No exercises match equipment ${woConfig.equipment} '
        'and muscle groups ${woConfig.muscleGroups} for "${woConfig.name}"',
      );
    }

    final estimatedWorkout = Workout(
      woConfig.name,
      exercisesWForWorkout,
      woConfig.muscleGroups,
      woConfig.startDelaySeconds,
      woConfig.finishDelaySeconds,
      0,
    );

    return Workout(
      woConfig.name,
      exercisesWForWorkout,
      woConfig.muscleGroups,
      woConfig.startDelaySeconds,
      woConfig.finishDelaySeconds,
      WorkoutDurationEstimator.estimateMinutes(estimatedWorkout),
    );
  }
}

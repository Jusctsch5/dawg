
import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/configuration/workout_configuration.dart';

import '../common_defines.dart';
import 'exercisew.dart';
import 'workout.dart';

class Decoder {


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
    // var filter = ExerciseFilterByGroups(equipment: woConfig.equipment, muscleGroups: woConfig.muscleGroups);
    // var totalExercises = exConfig.filterExercisesByGroups(filter);
    // exercises.shuffle();

    List<Exercise> exercisesForWorkout = [];
    List<ExerciseW> exercisesWForWorkout = [];
    var currentExerciseLengthSeconds = 0;

    var musclesToWork =  getMusclesForGroups(woConfig.muscleGroups);

    // Find an exercise for each muscle to work.
    while (currentExerciseLengthSeconds < woConfig.durationSeconds) {

      for (var muscleToWork in musclesToWork) {
        var muscleExercises = exConfig.filterExercises(ExerciseFilter(muscle: muscleToWork));
        var exerciseDef = getNewExerciseFromListOrRandom(muscleExercises, exercisesForWorkout);
        var exercisew = ExerciseW(exerciseDef, woConfig.setDurationSeconds, woConfig.setPerExercise);
        exercisesForWorkout.add(exerciseDef);
        exercisesWForWorkout.add(exercisew);
        currentExerciseLengthSeconds += exercisew.totalDuration;
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
    }

    return Workout(woConfig.name, woConfig, exercisesWForWorkout);
  }
}
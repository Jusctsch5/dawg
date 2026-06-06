import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/workout/exercisew.dart';
import 'package:dawg/workout/workout.dart';
import 'package:dawg/workout/workout_duration_estimator.dart';

/// Builds small single-exercise workouts for preview and wireframe testing.
class SampleWorkoutFactory {
  static const sampleSetDurationSeconds = 30;
  static const sampleSets = 3;
  static const sampleStartDelaySeconds = 30;
  static const sampleFinishDelaySeconds = 30;

  static Workout singleExercise(Exercise exercise) {
    final exerciseW = ExerciseW(exercise, sampleSetDurationSeconds, sampleSets);

    return Workout(
      'Sample: ${exercise.name}',
      [exerciseW],
      exercise.muscleGroups,
      sampleStartDelaySeconds,
      sampleFinishDelaySeconds,
      WorkoutDurationEstimator.estimateMinutesFor(
        exercises: [exerciseW],
        startDelaySeconds: sampleStartDelaySeconds,
        finishDelaySeconds: sampleFinishDelaySeconds,
      ),
    );
  }
}
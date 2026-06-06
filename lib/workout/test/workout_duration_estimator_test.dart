import 'package:dawg/common_defines.dart';
import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/workout/exercisew.dart';
import 'package:dawg/workout/sample_workout_factory.dart';
import 'package:dawg/workout/workout.dart';
import 'package:dawg/workout/workout_duration_estimator.dart';
import 'package:test/test.dart';

void main() {
  group('WorkoutDurationEstimator', () {
    test('sample workout is about three minutes', () {
      final exercise = Exercise(
        name: 'Pull Aparts',
        description: 'Test',
        equipment: [Equipment.resistanceBand],
        muscleGroups: [MuscleGroup.arms],
        muscles: [Muscle.biceps],
        alt: false,
      );

      final workout = SampleWorkoutFactory.singleExercise(exercise);

      expect(WorkoutDurationEstimator.estimateTimedSeconds(workout), 170);
      expect(WorkoutDurationEstimator.estimateMinutes(workout), 3);
      expect(workout.durationMinutes, 3);
    });

    test('matches player set and delay structure', () {
      final workout = Workout(
        'Test',
        [ExerciseW(_dummyExercise(), 90, 3)],
        const [],
        30,
        30,
        0,
      );

      // intro 30 + 3×90 sets + 2×10 between sets + finish 30
      expect(WorkoutDurationEstimator.estimateTimedSeconds(workout), 350);
      expect(WorkoutDurationEstimator.estimateMinutes(workout), 6);
    });
  });
}

Exercise _dummyExercise() {
  return Exercise(
    name: 'Test',
    description: 'Test',
    equipment: [Equipment.none],
    muscleGroups: [MuscleGroup.arms],
    muscles: [Muscle.biceps],
    alt: false,
  );
}

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



    test('exerciseTimedSeconds includes setup and between-set gaps', () {

      // 3×30s sets, 30s start delay: intro 30 + sets 90 + between 20 = 140

      expect(

        WorkoutDurationEstimator.exerciseTimedSeconds(

          setDurationSeconds: 30,

          sets: 3,

          startDelaySeconds: 30,

        ),

        140,

      );

      expect(

        WorkoutDurationEstimator.exerciseTimedSeconds(

          setDurationSeconds: 30,

          sets: 3,

          startDelaySeconds: 30,

        ),

        90 + 50,

      );

    });



    test('20 minute budget fits fewer exercises than set-seconds alone', () {

      const targetSeconds = 20 * 60;

      const finishSeconds = 60;

      final perExercise = WorkoutDurationEstimator.exerciseTimedSeconds(

        setDurationSeconds: 30,

        sets: 3,

        startDelaySeconds: 30,

      );



      final budget = WorkoutDurationEstimator.exerciseBudgetSeconds(

        targetSeconds,

        finishSeconds,

      );

      final maxExercises = budget ~/ perExercise;



      expect(perExercise, 140);

      expect(maxExercises, lessThan(14));

      expect(maxExercises, 8);

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



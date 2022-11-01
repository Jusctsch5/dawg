import 'package:dawg/configuration/workout_configuration.dart';

import 'exercisew.dart';

class Workout {

  final String name;
  final List<ExerciseW> exercises;
  final WorkoutConfiguration config;

  Workout(this.name, this.config, this.exercises);
}
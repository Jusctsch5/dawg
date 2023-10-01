import 'package:dawg/common_defines.dart';

import 'exercisew.dart';

class Workout {
  final String name;
  final List<ExerciseW> exercises;
  final List<MuscleGroup> muscleGroups;
  final int startDelaySeconds;
  final int finishDelaySeconds;
  final int durationMinutes;

  Workout(this.name, this.exercises, this.muscleGroups, this.startDelaySeconds, this.finishDelaySeconds, this.durationMinutes);
}

import 'package:dawg/configuration/exercise_configuration.dart';

class ExerciseW {
  final Exercise exercise;
  final int setDuration;
  final int sets;

  /// Active work only (sets × set duration). For full player time use
  /// [WorkoutDurationEstimator.exerciseTimedSecondsFor].
  int get activeSetSeconds => setDuration * sets;

  ExerciseW(this.exercise, this.setDuration, this.sets);
}

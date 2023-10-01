import 'package:dawg/configuration/exercise_configuration.dart';

class ExerciseW {
  final Exercise exercise;
  final int setDuration;
  final int sets;
  final int totalDuration;

  ExerciseW(this.exercise, this.setDuration, this.sets) : totalDuration = setDuration * sets;
}

import 'dart:math';

import 'package:dawg/workout/exercisew.dart';
import 'package:dawg/workout/workout.dart';

/// Estimates how long the [Player] will spend in timed segments (excluding TTS).
class WorkoutDurationEstimator {
  static const countdownSeconds = 5;
  static const betweenSetDelaySeconds = 5;

  static int estimateTimedSeconds(Workout workout) {
    var total = 0;

    for (final exerciseW in workout.exercises) {
      total += _exerciseIntroSeconds(workout.startDelaySeconds);
      total += _setsTimedSeconds(exerciseW.setDuration, exerciseW.sets);
    }

    total += _finishSeconds(workout.finishDelaySeconds);
    return total;
  }

  static int estimateMinutes(Workout workout) {
    return max(1, (estimateTimedSeconds(workout) / 60).ceil());
  }

  static int estimateMinutesFor({
    required List<ExerciseW> exercises,
    required int startDelaySeconds,
    required int finishDelaySeconds,
  }) {
    return estimateMinutes(Workout(
      '',
      exercises,
      const [],
      startDelaySeconds,
      finishDelaySeconds,
      0,
    ));
  }

  static int _exerciseIntroSeconds(int startDelaySeconds) {
    return max(5, startDelaySeconds - countdownSeconds) + countdownSeconds;
  }

  static int _setsTimedSeconds(int setDuration, int sets) {
    if (sets <= 0) {
      return 0;
    }

    var total = 0;
    for (var set = 1; set <= sets; set++) {
      if (set > 1) {
        total += betweenSetDelaySeconds + countdownSeconds;
      }
      total += max(5, setDuration - countdownSeconds) + countdownSeconds;
    }
    return total;
  }

  static int _finishSeconds(int finishDelaySeconds) {
    return max(5, finishDelaySeconds - countdownSeconds) + countdownSeconds;
  }
}

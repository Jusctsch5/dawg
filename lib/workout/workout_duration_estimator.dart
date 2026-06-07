import 'dart:math';

import 'package:dawg/workout/exercisew.dart';
import 'package:dawg/workout/workout.dart';

/// Estimates how long the [Player] spends in timed segments (excluding TTS).
///
/// Keep in sync with [Player] delay/countdown structure.
class WorkoutDurationEstimator {
  static const countdownSeconds = 5;
  static const betweenSetDelaySeconds = 5;

  /// Timed seconds for one exercise: setup/countdown + all sets + between-set gaps.
  static int exerciseTimedSeconds({
    required int setDurationSeconds,
    required int sets,
    required int startDelaySeconds,
  }) {
    return _exerciseIntroSeconds(startDelaySeconds) +
        _setsTimedSeconds(setDurationSeconds, sets);
  }

  static int exerciseTimedSecondsFor(ExerciseW exerciseW, int startDelaySeconds) {
    return exerciseTimedSeconds(
      setDurationSeconds: exerciseW.setDuration,
      sets: exerciseW.sets,
      startDelaySeconds: startDelaySeconds,
    );
  }

  static int estimateTimedSeconds(Workout workout) {
    var total = 0;

    for (final exerciseW in workout.exercises) {
      total += exerciseTimedSecondsFor(exerciseW, workout.startDelaySeconds);
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

  /// Seconds budget for exercises when building a workout to a target duration.
  static int exerciseBudgetSeconds(int targetDurationSeconds, int finishDelaySeconds) {
    return max(0, targetDurationSeconds - _finishSeconds(finishDelaySeconds));
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

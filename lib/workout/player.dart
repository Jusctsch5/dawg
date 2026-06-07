import 'dart:math';

import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/workout.dart';
import 'package:dawg/workout/workout_playback_gate.dart';
import 'package:dawg/workout/workout_playback_state.dart';

class Player {
  Player({WorkoutPlaybackGate? gate}) : gate = gate ?? WorkoutPlaybackGate();

  final WorkoutPlaybackGate gate;

  void cancel() {
    gate.cancel();
  }

  void reset() {
    gate.reset();
  }

  Future<void> playWorkout(
    Workout workout,
    Announcer announcer, {
    WorkoutPlaybackListener? onStateChanged,
  }) async {
    gate.reset();

    void notify(WorkoutPlaybackState state) {
      onStateChanged?.call(state.copyWith(isPaused: gate.paused));
    }

    notify(const WorkoutPlaybackState(
      isPlaying: true,
      segment: WorkoutSegment.intro,
      statusLabel: 'Starting workout',
    ));

    if (!await announcer.announce("Starting Workout: ${workout.name}")) return;
    if (!await announcer.announce(
      "This workout will take approximately ${workout.durationMinutes} minutes ",
    )) return;

    for (var exerciseIndex = 0; exerciseIndex < workout.exercises.length; exerciseIndex++) {
      final exerciseW = workout.exercises[exerciseIndex];

      notify(WorkoutPlaybackState(
        isPlaying: true,
        exerciseIndex: exerciseIndex,
        setCount: exerciseW.sets,
        segment: WorkoutSegment.preparingExercise,
        statusLabel: 'Up next: ${exerciseW.exercise.name}',
      ));

      if (!await announcer.announce("Next Exercise will be: ${exerciseW.exercise.name}")) return;

      notify(WorkoutPlaybackState(
        isPlaying: true,
        exerciseIndex: exerciseIndex,
        setCount: exerciseW.sets,
        segment: WorkoutSegment.exerciseDescription,
        statusLabel: exerciseW.exercise.name,
      ));

      if (!await announcer.announce(exerciseW.exercise.description)) return;

      notify(WorkoutPlaybackState(
        isPlaying: true,
        exerciseIndex: exerciseIndex,
        setCount: exerciseW.sets,
        segment: WorkoutSegment.preparingExercise,
        statusLabel: 'Up next: ${exerciseW.exercise.name}',
      ));

      final positionCue = 'Get into position for ${exerciseW.exercise.name}';
      if (!await announcer.announce(positionCue)) return;

      if (!await _runDelay(
        max(5, workout.startDelaySeconds - 5),
        WorkoutPlaybackState(
          isPlaying: true,
          exerciseIndex: exerciseIndex,
          setCount: exerciseW.sets,
          segment: WorkoutSegment.preparingExercise,
          statusLabel: positionCue,
        ),
        notify,
      )) return;

      if (!await _runStartExerciseCountdown(
        announcer,
        exerciseW.exercise.name,
        5,
        WorkoutPlaybackState(
          isPlaying: true,
          exerciseIndex: exerciseIndex,
          setCount: exerciseW.sets,
          segment: WorkoutSegment.countdown,
          statusLabel: 'Starting ${exerciseW.exercise.name}',
        ),
        notify,
      )) return;

      for (var setNumber = 1; setNumber <= exerciseW.sets; setNumber++) {
        if (setNumber > 1) {
          notify(WorkoutPlaybackState(
            isPlaying: true,
            exerciseIndex: exerciseIndex,
            setNumber: setNumber,
            setCount: exerciseW.sets,
            segment: WorkoutSegment.preparingExercise,
            statusLabel: 'Set $setNumber of ${exerciseW.sets}',
          ));

          if (!await announcer.announce("Continuing Exercise: ${exerciseW.exercise.name}")) return;
          if (exerciseW.exercise.alt) {
            if (!await announcer.announce("Change sides")) return;
          }

          if (!await _runDelay(
            5,
            WorkoutPlaybackState(
              isPlaying: true,
              exerciseIndex: exerciseIndex,
              setNumber: setNumber,
              setCount: exerciseW.sets,
              segment: WorkoutSegment.preparingExercise,
              statusLabel: 'Set $setNumber of ${exerciseW.sets}',
            ),
            notify,
          )) return;

          if (!await _runCountdown(
            announcer,
            5,
            WorkoutPlaybackState(
              isPlaying: true,
              exerciseIndex: exerciseIndex,
              setNumber: setNumber,
              setCount: exerciseW.sets,
              segment: WorkoutSegment.countdown,
              statusLabel: 'Set $setNumber',
            ),
            notify,
          )) return;
        }

        notify(WorkoutPlaybackState(
          isPlaying: true,
          exerciseIndex: exerciseIndex,
          setNumber: setNumber,
          setCount: exerciseW.sets,
          segment: WorkoutSegment.activeSet,
          statusLabel: 'Set $setNumber of ${exerciseW.sets}',
        ));

        if (!await announcer.announce(
          "Set $setNumber of ${exerciseW.sets} of ${exerciseW.exercise.name}, Ready Go!",
        )) return;

        if (!await _runDelay(
          max(5, exerciseW.setDuration - 5),
          WorkoutPlaybackState(
            isPlaying: true,
            exerciseIndex: exerciseIndex,
            setNumber: setNumber,
            setCount: exerciseW.sets,
            segment: WorkoutSegment.activeSet,
            statusLabel: 'Set $setNumber of ${exerciseW.sets}',
          ),
          notify,
        )) return;

        if (!await _runCountdown(
          announcer,
          5,
          WorkoutPlaybackState(
            isPlaying: true,
            exerciseIndex: exerciseIndex,
            setNumber: setNumber,
            setCount: exerciseW.sets,
            segment: WorkoutSegment.countdown,
            statusLabel: 'Finishing set $setNumber',
          ),
          notify,
        )) return;
      }

      notify(WorkoutPlaybackState(
        isPlaying: true,
        exerciseIndex: exerciseIndex,
        setCount: exerciseW.sets,
        segment: WorkoutSegment.exerciseRest,
        statusLabel: 'Cooldown',
      ));

      if (!await announcer.announce("Finished Exercise: ${exerciseW.exercise.name}")) return;
      if (!await announcer.announce("Exercise cooldown for ${workout.startDelaySeconds} seconds")) return;
    }

    notify(const WorkoutPlaybackState(
      isPlaying: true,
      segment: WorkoutSegment.workoutFinish,
      statusLabel: 'Cool down',
    ));

    if (!await announcer.announce("Exercises for Workout: ${workout.name} Finished")) return;
    if (!await announcer.announce("Work it off for: ${workout.finishDelaySeconds} seconds")) return;

    if (!await _runDelay(
      max(5, workout.finishDelaySeconds - 5),
      const WorkoutPlaybackState(
        isPlaying: true,
        segment: WorkoutSegment.workoutFinish,
        statusLabel: 'Cool down',
      ),
      notify,
    )) return;

    if (!await _runCountdown(
      announcer,
      5,
      const WorkoutPlaybackState(
        isPlaying: true,
        segment: WorkoutSegment.workoutFinish,
        statusLabel: 'Almost done',
      ),
      notify,
    )) return;

    await announcer.announce("Finished Workout: ${workout.name}. Great Job.");

    notify(const WorkoutPlaybackState(
      isPlaying: false,
      segment: WorkoutSegment.finished,
      segmentProgress: 1,
      statusLabel: 'Workout complete',
    ));
  }

  Future<bool> _runDelay(
    int seconds,
    WorkoutPlaybackState state,
    WorkoutPlaybackListener notify,
  ) async {
    if (seconds <= 0) {
      notify(state.copyWith(segmentProgress: 1));
      return true;
    }

    for (var elapsed = 0; elapsed < seconds; elapsed++) {
      for (var tick = 0; tick < 10; tick++) {
        if (!await gate.proceed()) return false;
        await Future.delayed(const Duration(milliseconds: 100));
        notify(state.copyWith(segmentProgress: (elapsed + (tick + 1) / 10) / seconds));
      }
    }
    return true;
  }

  Future<bool> _runStartExerciseCountdown(
    Announcer announcer,
    String exerciseName,
    int from,
    WorkoutPlaybackState state,
    WorkoutPlaybackListener notify,
  ) async {
    for (var remaining = from; remaining > 0; remaining--) {
      if (!await gate.proceed()) return false;
      notify(state.copyWith(
        segmentProgress: (from - remaining) / from,
        statusLabel: '${state.statusLabel} — $remaining',
      ));
      if (remaining == from) {
        if (!await announcer.announce('Starting Exercise $exerciseName in $remaining')) return false;
      } else {
        if (!await announcer.announce(remaining.toString())) return false;
      }
    }
    notify(state.copyWith(segmentProgress: 1));
    return true;
  }

  Future<bool> _runCountdown(
    Announcer announcer,
    int from,
    WorkoutPlaybackState state,
    WorkoutPlaybackListener notify,
  ) async {
    for (var remaining = from; remaining > 0; remaining--) {
      if (!await gate.proceed()) return false;
      notify(state.copyWith(
        segmentProgress: (from - remaining) / from,
        statusLabel: '${state.statusLabel} — $remaining',
      ));
      if (!await announcer.announce(remaining.toString())) return false;
    }
    notify(state.copyWith(segmentProgress: 1));
    return true;
  }
}

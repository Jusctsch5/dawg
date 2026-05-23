import 'dart:math';

import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/workout.dart';
import 'package:dawg/workout/workout_playback_state.dart';

class Player {
  bool _cancelled = false;

  void cancel() {
    _cancelled = true;
  }

  void reset() {
    _cancelled = false;
  }

  Future<void> playWorkout(
    Workout workout,
    Announcer announcer, {
    WorkoutPlaybackListener? onStateChanged,
  }) async {
    _cancelled = false;

    void notify(WorkoutPlaybackState state) {
      onStateChanged?.call(state);
    }

    notify(const WorkoutPlaybackState(
      isPlaying: true,
      segment: WorkoutSegment.intro,
      statusLabel: 'Starting workout',
    ));

    await announcer.announce("Starting Workout: ${workout.name}");
    if (_cancelled) return;
    await announcer.announce("This workout will take approximately ${workout.durationMinutes} minutes ");
    if (_cancelled) return;

    for (var exerciseIndex = 0; exerciseIndex < workout.exercises.length; exerciseIndex++) {
      final exerciseW = workout.exercises[exerciseIndex];

      notify(WorkoutPlaybackState(
        isPlaying: true,
        exerciseIndex: exerciseIndex,
        setCount: exerciseW.sets,
        segment: WorkoutSegment.preparingExercise,
        statusLabel: 'Up next: ${exerciseW.exercise.name}',
      ));

      await announcer.announce("Next Exercise will be: ${exerciseW.exercise.name}");
      if (_cancelled) return;
      await announcer.announce(exerciseW.exercise.description);
      if (_cancelled) return;

      final positionCue = 'Get into position for ${exerciseW.exercise.name}';
      await announcer.announce(positionCue);
      if (_cancelled) return;

      await _runDelay(
        max(5, workout.startDelaySeconds - 5),
        WorkoutPlaybackState(
          isPlaying: true,
          exerciseIndex: exerciseIndex,
          setCount: exerciseW.sets,
          segment: WorkoutSegment.preparingExercise,
          statusLabel: positionCue,
        ),
        notify,
      );
      if (_cancelled) return;

      await _runStartExerciseCountdown(
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
      );
      if (_cancelled) return;

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

          await announcer.announce("Continuing Exercise: ${exerciseW.exercise.name}");
          if (_cancelled) return;
          if (exerciseW.exercise.alt) {
            await announcer.announce("Change sides");
            if (_cancelled) return;
          }

          final setPositionCue = 'Get into position for ${exerciseW.exercise.name}';
          await announcer.announce(setPositionCue);
          if (_cancelled) return;

          await _runDelay(
            5,
            WorkoutPlaybackState(
              isPlaying: true,
              exerciseIndex: exerciseIndex,
              setNumber: setNumber,
              setCount: exerciseW.sets,
              segment: WorkoutSegment.preparingExercise,
              statusLabel: setPositionCue,
            ),
            notify,
          );
          if (_cancelled) return;

          await _runCountdown(
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
          );
          if (_cancelled) return;
        }

        notify(WorkoutPlaybackState(
          isPlaying: true,
          exerciseIndex: exerciseIndex,
          setNumber: setNumber,
          setCount: exerciseW.sets,
          segment: WorkoutSegment.activeSet,
          statusLabel: 'Set $setNumber of ${exerciseW.sets}',
        ));

        await announcer.announce(
          "Set $setNumber of ${exerciseW.sets} of ${exerciseW.exercise.name}, Ready Go!",
        );
        if (_cancelled) return;

        await _runDelay(
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
        );
        if (_cancelled) return;

        await _runCountdown(
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
        );
        if (_cancelled) return;
      }

      notify(WorkoutPlaybackState(
        isPlaying: true,
        exerciseIndex: exerciseIndex,
        setCount: exerciseW.sets,
        segment: WorkoutSegment.exerciseRest,
        statusLabel: 'Cooldown',
      ));

      await announcer.announce("Finished Exercise: ${exerciseW.exercise.name}");
      if (_cancelled) return;
      await announcer.announce("Exercise cooldown for ${workout.startDelaySeconds} seconds");
      if (_cancelled) return;
    }

    notify(const WorkoutPlaybackState(
      isPlaying: true,
      segment: WorkoutSegment.workoutFinish,
      statusLabel: 'Cool down',
    ));

    await announcer.announce("Exercises for Workout: ${workout.name} Finished");
    if (_cancelled) return;
    await announcer.announce("Work it off for: ${workout.finishDelaySeconds} seconds");
    if (_cancelled) return;

    await _runDelay(
      max(5, workout.finishDelaySeconds - 5),
      const WorkoutPlaybackState(
        isPlaying: true,
        segment: WorkoutSegment.workoutFinish,
        statusLabel: 'Cool down',
      ),
      notify,
    );
    if (_cancelled) return;

    await _runCountdown(
      announcer,
      5,
      const WorkoutPlaybackState(
        isPlaying: true,
        segment: WorkoutSegment.workoutFinish,
        statusLabel: 'Almost done',
      ),
      notify,
    );
    if (_cancelled) return;

    await announcer.announce("Finished Workout: ${workout.name}. Great Job.");

    notify(const WorkoutPlaybackState(
      isPlaying: false,
      segment: WorkoutSegment.finished,
      segmentProgress: 1,
      statusLabel: 'Workout complete',
    ));
  }

  Future<void> _runDelay(
    int seconds,
    WorkoutPlaybackState state,
    WorkoutPlaybackListener notify,
  ) async {
    if (seconds <= 0) {
      notify(state.copyWith(segmentProgress: 1));
      return;
    }

    for (var elapsed = 0; elapsed < seconds; elapsed++) {
      if (_cancelled) return;
      for (var tick = 0; tick < 10; tick++) {
        if (_cancelled) return;
        await Future.delayed(const Duration(milliseconds: 100));
        notify(state.copyWith(segmentProgress: (elapsed + (tick + 1) / 10) / seconds));
      }
    }
  }

  Future<void> _runStartExerciseCountdown(
    Announcer announcer,
    String exerciseName,
    int from,
    WorkoutPlaybackState state,
    WorkoutPlaybackListener notify,
  ) async {
    for (var remaining = from; remaining > 0; remaining--) {
      if (_cancelled) return;
      notify(state.copyWith(
        segmentProgress: (from - remaining) / from,
        statusLabel: '${state.statusLabel} — $remaining',
      ));
      if (remaining == from) {
        await announcer.announce('Starting Exercise $exerciseName in $remaining');
      } else {
        await announcer.announce(remaining.toString());
      }
      if (_cancelled) return;
    }
    notify(state.copyWith(segmentProgress: 1));
  }

  Future<void> _runCountdown(
    Announcer announcer,
    int from,
    WorkoutPlaybackState state,
    WorkoutPlaybackListener notify,
  ) async {
    for (var remaining = from; remaining > 0; remaining--) {
      if (_cancelled) return;
      notify(state.copyWith(
        segmentProgress: (from - remaining) / from,
        statusLabel: '${state.statusLabel} — $remaining',
      ));
      await announcer.announce(remaining.toString());
      if (_cancelled) return;
    }
    notify(state.copyWith(segmentProgress: 1));
  }
}

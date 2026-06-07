enum WorkoutSegment {
  idle,
  intro,
  preparingExercise,
  exerciseDescription,
  countdown,
  activeSet,
  exerciseRest,
  workoutFinish,
  finished,
}

class WorkoutPlaybackState {
  const WorkoutPlaybackState({
    this.isPlaying = false,
    this.isPaused = false,
    this.exerciseIndex = -1,
    this.setNumber = 0,
    this.setCount = 0,
    this.segment = WorkoutSegment.idle,
    this.segmentProgress = 0,
    this.statusLabel = '',
  });

  final bool isPlaying;
  final bool isPaused;
  final int exerciseIndex;
  final int setNumber;
  final int setCount;
  final WorkoutSegment segment;
  final double segmentProgress;
  final String statusLabel;

  WorkoutPlaybackState copyWith({
    bool? isPlaying,
    bool? isPaused,
    int? exerciseIndex,
    int? setNumber,
    int? setCount,
    WorkoutSegment? segment,
    double? segmentProgress,
    String? statusLabel,
  }) {
    return WorkoutPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      setNumber: setNumber ?? this.setNumber,
      setCount: setCount ?? this.setCount,
      segment: segment ?? this.segment,
      segmentProgress: segmentProgress ?? this.segmentProgress,
      statusLabel: statusLabel ?? this.statusLabel,
    );
  }
}

typedef WorkoutPlaybackListener = void Function(WorkoutPlaybackState state);

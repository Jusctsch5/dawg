import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/exercisew.dart';
import 'package:dawg/workout/player.dart';
import 'package:dawg/workout/workout.dart';
import 'package:dawg/workout/workout_playback_state.dart';
import 'package:flutter/material.dart';

class ActiveWorkoutPage extends StatefulWidget {
  const ActiveWorkoutPage({super.key, required this.workout});

  final Workout workout;

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  final _player = Player();
  final _announcer = AnnouncerTts();
  final _exerciseListController = ScrollController();
  late final List<GlobalKey> _exerciseRowKeys;

  WorkoutPlaybackState _playbackState = const WorkoutPlaybackState();
  int? _lastScrolledExerciseIndex;

  @override
  void initState() {
    super.initState();
    _exerciseRowKeys = List.generate(
      widget.workout.exercises.length,
      (_) => GlobalKey(),
    );
  }

  @override
  void dispose() {
    _player.cancel();
    _exerciseListController.dispose();
    super.dispose();
  }

  void _startWorkout() {
    if (_playbackState.isPlaying) return;

    setState(() {
      _playbackState = const WorkoutPlaybackState(isPlaying: true);
    });

    _player.playWorkout(
      widget.workout,
      _announcer,
      onStateChanged: _onPlaybackStateChanged,
    ).whenComplete(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onPlaybackStateChanged(WorkoutPlaybackState state) {
    if (!mounted) return;

    setState(() {
      _playbackState = state;
    });

    final index = state.exerciseIndex;
    if (index >= 0 && index != _lastScrolledExerciseIndex) {
      _lastScrolledExerciseIndex = index;
      _scrollToExercise(index);
    }
  }

  void _scrollToExercise(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index < 0 || index >= _exerciseRowKeys.length) return;

      final context = _exerciseRowKeys[index].currentContext;
      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.05,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  ExerciseW? get _activeExercise {
    final index = _playbackState.exerciseIndex;
    if (index < 0 || index >= widget.workout.exercises.length) {
      return null;
    }
    return widget.workout.exercises[index];
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playbackState.isPlaying;
    final activeExercise = _activeExercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _ExerciseDemoPlaceholder(
              exercise: activeExercise,
              isPlaying: isPlaying,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 3,
            child: _ExerciseTable(
              exercises: widget.workout.exercises,
              activeIndex: _playbackState.exerciseIndex,
              scrollController: _exerciseListController,
              rowKeys: _exerciseRowKeys,
            ),
          ),
        ],
      ),
      floatingActionButton: !isPlaying && _playbackState.segment != WorkoutSegment.finished
          ? FloatingActionButton.extended(
              onPressed: _startWorkout,
              icon: const Icon(Icons.play_arrow),
              label: const Text('GO!'),
            )
          : null,
      bottomNavigationBar: isPlaying ? _WorkoutPlayerBar(state: _playbackState, exercise: activeExercise) : null,
    );
  }
}

class _ExerciseDemoPlaceholder extends StatelessWidget {
  const _ExerciseDemoPlaceholder({
    required this.exercise,
    required this.isPlaying,
  });

  final ExerciseW? exercise;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: exercise == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.accessibility_new, size: 72, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Exercise demo',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Wireframe avatar coming soon',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPlaying ? Icons.directions_run : Icons.fitness_center,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        exercise!.exercise.name,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        exercise!.exercise.description,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Avatar demo placeholder',
                        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseTable extends StatelessWidget {
  const _ExerciseTable({
    required this.exercises,
    required this.activeIndex,
    required this.scrollController,
    required this.rowKeys,
  });

  final List<ExerciseW> exercises;
  final int activeIndex;
  final ScrollController scrollController;
  final List<GlobalKey> rowKeys;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 36, child: Text('#', style: theme.textTheme.labelLarge)),
              Expanded(flex: 3, child: Text('Exercise', style: theme.textTheme.labelLarge)),
              Expanded(child: Text('Sets', style: theme.textTheme.labelLarge, textAlign: TextAlign.center)),
              Expanded(child: Text('Duration', style: theme.textTheme.labelLarge, textAlign: TextAlign.end)),
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            child: ListView.builder(
              controller: scrollController,
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exerciseW = exercises[index];
                final isActive = index == activeIndex;

                return Material(
                  key: rowKeys[index],
                  color: isActive ? theme.colorScheme.primaryContainer : null,
                  child: ListTile(
                    dense: true,
                    leading: SizedBox(
                      width: 36,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    title: Text(
                      exerciseW.exercise.name,
                      style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                    ),
                    subtitle: isActive ? const Text('Now playing') : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${exerciseW.sets}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        SizedBox(
                          width: 72,
                          child: Text(
                            '${exerciseW.totalDuration}s',
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutPlayerBar extends StatelessWidget {
  const _WorkoutPlayerBar({
    required this.state,
    required this.exercise,
  });

  final WorkoutPlaybackState state;
  final ExerciseW? exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = exercise?.exercise.name ?? 'Workout';
    final subtitle = state.statusLabel;

    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.segmentProgress.clamp(0, 1),
                  minHeight: 8,
                ),
              ),
              if (state.setNumber > 0 && state.setCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Set ${state.setNumber} of ${state.setCount}',
                  style: theme.textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

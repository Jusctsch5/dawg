import 'package:dawg/ui/avatar/exercise_wireframe_view.dart';
import 'package:dawg/ui/avatar/wireframe_avatar.dart';
import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/exercisew.dart';
import 'package:dawg/workout/player.dart';
import 'package:dawg/workout/workout.dart';
import 'package:dawg/workout/workout_playback_gate.dart';
import 'package:dawg/workout/workout_playback_state.dart';
import 'package:flutter/material.dart';

class ActiveWorkoutPage extends StatefulWidget {
  const ActiveWorkoutPage({super.key, required this.workout});

  final Workout workout;

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  late final WorkoutPlaybackGate _gate;
  late final Player _player;
  late final AnnouncerTts _announcer;
  final _exerciseListController = ScrollController();
  late final List<GlobalKey> _exerciseRowKeys;

  WorkoutPlaybackState _playbackState = const WorkoutPlaybackState();
  int _selectedExerciseIndex = 0;
  int? _lastScrolledExerciseIndex;

  @override
  void initState() {
    super.initState();
    _gate = WorkoutPlaybackGate();
    _player = Player(gate: _gate);
    _announcer = AnnouncerTts(gate: _gate);
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

  void _togglePause() {
    if (!_playbackState.isPlaying || _playbackState.segment == WorkoutSegment.finished) {
      return;
    }

    setState(() {
      if (_gate.paused) {
        _gate.resume();
        _playbackState = _playbackState.copyWith(isPaused: false);
      } else {
        _gate.pause();
        _playbackState = _playbackState.copyWith(isPaused: true);
      }
    });
  }

  void _onPlaybackStateChanged(WorkoutPlaybackState state) {
    if (!mounted) return;

    setState(() {
      _playbackState = state;
      if (state.exerciseIndex >= 0) {
        _selectedExerciseIndex = state.exerciseIndex;
      }
    });

    final index = state.exerciseIndex;
    if (index >= 0 && index != _lastScrolledExerciseIndex) {
      _lastScrolledExerciseIndex = index;
      _scrollToExercise(index);
    }
  }

  void _selectExercise(int index) {
    if (index < 0 || index >= widget.workout.exercises.length) return;
    setState(() => _selectedExerciseIndex = index);
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
    if (_selectedExerciseIndex < 0 || _selectedExerciseIndex >= widget.workout.exercises.length) {
      return null;
    }
    return widget.workout.exercises[_selectedExerciseIndex];
  }

  WorkoutPlaybackState get _demoPlaybackState {
    if (!_playbackState.isPlaying) {
      return _playbackState;
    }
    if (_selectedExerciseIndex == _playbackState.exerciseIndex) {
      return _playbackState;
    }
    return WorkoutPlaybackState(isPaused: _playbackState.isPaused);
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
            flex: 3,
            child: _ExerciseDemoPlaceholder(
              exercise: activeExercise,
              playbackState: _demoPlaybackState,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: _ExerciseTable(
              exercises: widget.workout.exercises,
              selectedIndex: _selectedExerciseIndex,
              playingIndex: _playbackState.exerciseIndex,
              isPlaying: isPlaying,
              onExerciseSelected: _selectExercise,
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
      bottomNavigationBar: isPlaying
          ? _WorkoutPlayerBar(
              state: _playbackState,
              exercise: activeExercise,
              onTogglePause: _togglePause,
            )
          : null,
    );
  }
}

class _ExerciseDemoPlaceholder extends StatelessWidget {
  const _ExerciseDemoPlaceholder({
    required this.exercise,
    required this.playbackState,
  });

  final ExerciseW? exercise;
  final WorkoutPlaybackState playbackState;

  Widget _wireframe(Color color) {
    return ExerciseWireframeView(
      exerciseName: exercise?.exercise.name,
      equipment: exercise?.exercise.equipment ?? const [],
      playbackState: playbackState,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sideLayout = constraints.maxWidth >= 480;

            if (sideLayout) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: _ExerciseSidePanel(
                      alignment: Alignment.topLeft,
                      child: exercise != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise!.exercise.name,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      exercise!.exercise.description,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Exercise demo',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  neutralStandingFront.label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _wireframe(theme.colorScheme.primary),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise != null) ...[
                  Text(
                    exercise!.exercise.name,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise!.exercise.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Text(
                    'Exercise demo',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    neutralStandingFront.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: _wireframe(theme.colorScheme.primary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseSidePanel extends StatelessWidget {
  const _ExerciseSidePanel({
    required this.alignment,
    required this.child,
  });

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Align(
        alignment: alignment,
        child: child,
      ),
    );
  }
}

class _ExerciseTable extends StatelessWidget {
  const _ExerciseTable({
    required this.exercises,
    required this.selectedIndex,
    required this.playingIndex,
    required this.isPlaying,
    required this.onExerciseSelected,
    required this.scrollController,
    required this.rowKeys,
  });

  final List<ExerciseW> exercises;
  final int selectedIndex;
  final int playingIndex;
  final bool isPlaying;
  final ValueChanged<int> onExerciseSelected;
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
                final isSelected = index == selectedIndex;
                final isNowPlaying = isPlaying && index == playingIndex;

                return Material(
                  key: rowKeys[index],
                  color: isSelected ? theme.colorScheme.primaryContainer : null,
                  child: ListTile(
                    dense: true,
                    selected: isSelected,
                    onTap: () => onExerciseSelected(index),
                    leading: SizedBox(
                      width: 36,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    title: Text(
                      exerciseW.exercise.name,
                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                    subtitle: isNowPlaying ? const Text('Now playing') : null,
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
    required this.onTogglePause,
  });

  final WorkoutPlaybackState state;
  final ExerciseW? exercise;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = exercise?.exercise.name ?? 'Workout';
    final subtitle = state.isPaused ? 'Paused' : state.statusLabel;

    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onTogglePause,
                icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                tooltip: state.isPaused ? 'Resume' : 'Pause',
              ),
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }
}

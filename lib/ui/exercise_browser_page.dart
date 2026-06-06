import 'package:dawg/common_defines.dart';
import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/data/exercise_repository.dart';
import 'package:dawg/ui/active_workout_page.dart';
import 'package:dawg/workout/sample_workout_factory.dart';
import 'package:flutter/material.dart';

class ExerciseBrowserPage extends StatefulWidget {
  const ExerciseBrowserPage({super.key});

  @override
  State<ExerciseBrowserPage> createState() => _ExerciseBrowserPageState();
}

class _ExerciseBrowserPageState extends State<ExerciseBrowserPage> {
  late final Future<List<Exercise>> _exercisesFuture;
  final Set<MuscleGroup> _selectedMuscleGroups = {};
  final Set<Equipment> _selectedEquipment = {};

  static const _libraryEquipment = [
    Equipment.resistanceBand,
    Equipment.suspendedBand,
    Equipment.gluteBand,
    Equipment.ring,
    Equipment.freeWeight,
  ];

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _loadSortedExercises();
  }

  Future<List<Exercise>> _loadSortedExercises() async {
    final config = await ExerciseRepository.instance.loadExercises();
    final exercises = List<Exercise>.from(config.exercises)
      ..sort((a, b) => a.name.compareTo(b.name));
    return exercises;
  }

  void _openSampleWorkout(Exercise exercise) {
    final workout = SampleWorkoutFactory.singleExercise(exercise);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActiveWorkoutPage(workout: workout)),
    );
  }

  void _toggleMuscleGroup(MuscleGroup group) {
    setState(() {
      if (_selectedMuscleGroups.contains(group)) {
        _selectedMuscleGroups.remove(group);
      } else {
        _selectedMuscleGroups.add(group);
      }
    });
  }

  void _toggleEquipment(Equipment equipment) {
    setState(() {
      if (_selectedEquipment.contains(equipment)) {
        _selectedEquipment.remove(equipment);
      } else {
        _selectedEquipment.add(equipment);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedMuscleGroups.clear();
      _selectedEquipment.clear();
    });
  }

  bool get _hasActiveFilters =>
      _selectedMuscleGroups.isNotEmpty || _selectedEquipment.isNotEmpty;

  List<Exercise> _applyFilters(List<Exercise> exercises) {
    return exercises.where((exercise) {
      if (_selectedMuscleGroups.isNotEmpty &&
          !exercise.muscleGroups.any(_selectedMuscleGroups.contains)) {
        return false;
      }

      if (_selectedEquipment.isNotEmpty) {
        final equipment = exercise.equipment.isEmpty
            ? const [Equipment.none]
            : exercise.equipment;
        if (!equipment.any(_selectedEquipment.contains)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Set<MuscleGroup> _availableMuscleGroups(List<Exercise> exercises) {
    return exercises.expand((exercise) => exercise.muscleGroups).toSet();
  }

  Set<Equipment> _availableEquipment(List<Exercise> exercises) {
    return exercises
        .expand((exercise) => exercise.equipment.isEmpty ? [Equipment.none] : exercise.equipment)
        .where((equipment) => equipment != Equipment.all && equipment != Equipment.none)
        .toSet();
  }

  String _equipmentLabel(Exercise exercise) {
    if (exercise.equipment.isEmpty ||
        exercise.equipment.every((e) => e == Equipment.none)) {
      return 'Bodyweight';
    }
    return exercise.equipment
        .where((e) => e != Equipment.none && e != Equipment.all)
        .map(_equipmentDisplayName)
        .join(', ');
  }

  String _muscleGroupLabel(Exercise exercise) {
    return exercise.muscleGroups.map(_muscleGroupDisplayName).join(', ');
  }

  static String _muscleGroupDisplayName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.abdominals:
        return 'Abdominals';
      case MuscleGroup.arms:
        return 'Arms';
      case MuscleGroup.legs:
        return 'Legs';
    }
  }

  static String _equipmentDisplayName(Equipment equipment) {
    switch (equipment) {
      case Equipment.resistanceBand:
        return 'Resistance band';
      case Equipment.suspendedBand:
        return 'Suspended band';
      case Equipment.gluteBand:
        return 'Glute band';
      case Equipment.ring:
        return 'Ring';
      case Equipment.freeWeight:
        return 'Free weight';
      case Equipment.all:
        return 'All';
      case Equipment.none:
        return 'Bodyweight';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load exercises: ${snapshot.error}'));
          }

          final allExercises = snapshot.data ?? [];
          if (allExercises.isEmpty) {
            return const Center(child: Text('No exercises found.'));
          }

          final filteredExercises = _applyFilters(allExercises);
          final availableMuscleGroups = _availableMuscleGroups(allExercises).toList()
            ..sort((a, b) => _muscleGroupDisplayName(a).compareTo(_muscleGroupDisplayName(b)));
          final availableEquipment = _libraryEquipment
              .where(_availableEquipment(allExercises).contains)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                elevation: 1,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Muscle group',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final group in availableMuscleGroups)
                            FilterChip(
                              label: Text(_muscleGroupDisplayName(group)),
                              selected: _selectedMuscleGroups.contains(group),
                              onSelected: (_) => _toggleMuscleGroup(group),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Equipment',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final equipment in availableEquipment)
                            FilterChip(
                              label: Text(_equipmentDisplayName(equipment)),
                              selected: _selectedEquipment.contains(equipment),
                              onSelected: (_) => _toggleEquipment(equipment),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _hasActiveFilters
                            ? '${filteredExercises.length} of ${allExercises.length} exercises'
                            : '${allExercises.length} exercises',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filteredExercises.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises match the selected filters.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Scrollbar(
                        child: ListView.separated(
                          itemCount: filteredExercises.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final exercise = filteredExercises[index];
                            return ListTile(
                              onTap: () => _openSampleWorkout(exercise),
                              title: Text(exercise.name),
                              subtitle: Text(
                                '${_muscleGroupLabel(exercise)} · ${_equipmentLabel(exercise)}',
                              ),
                              trailing: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('3 × ${SampleWorkoutFactory.sampleSetDurationSeconds}s'),
                                  Icon(Icons.play_arrow),
                                ],
                              ),
                              isThreeLine: false,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

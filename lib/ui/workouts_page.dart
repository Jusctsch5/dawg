import 'package:dawg/common_defines.dart';
import 'package:dawg/configuration/workout_configuration.dart';
import 'package:dawg/data/exercise_repository.dart';
import 'package:dawg/ui/active_workout_page.dart';
import 'package:dawg/workout/decoder.dart';
import 'package:flutter/material.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  late final Future<List<WorkoutConfiguration>> _workoutsFuture;

  final Set<MuscleGroup> _customMuscleGroups = {};
  final Set<Equipment> _customEquipment = {};
  int _customDurationMinutes = 20;
  bool _createExpanded = true;
  bool _presetsExpanded = false;

  static const _customEquipmentOptions = [
    Equipment.resistanceBand,
    Equipment.suspendedBand,
    Equipment.gluteBand,
    Equipment.ring,
    Equipment.freeWeight,
  ];

  static const _durationOptions = [10, 15, 20, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _workoutsFuture = ExerciseRepository.instance.loadWorkoutConfigs();
  }

  Future<void> _openWorkout(WorkoutConfiguration config) async {
    final exerciseConfig = await ExerciseRepository.instance.loadExercises();
    final workout = Decoder().generateWorkout(config, exerciseConfig);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActiveWorkoutPage(workout: workout)),
    );
  }

  void _toggleCustomMuscleGroup(MuscleGroup group) {
    setState(() {
      if (_customMuscleGroups.contains(group)) {
        _customMuscleGroups.remove(group);
      } else {
        _customMuscleGroups.add(group);
      }
    });
  }

  void _toggleCustomEquipment(Equipment equipment) {
    setState(() {
      if (_customEquipment.contains(equipment)) {
        _customEquipment.remove(equipment);
      } else {
        _customEquipment.add(equipment);
      }
    });
  }

  void _generateCustomWorkout() {
    final config = WorkoutConfiguration.custom(
      muscleGroups: _customMuscleGroups.toList()
        ..sort((a, b) => a.index.compareTo(b.index)),
      equipment: _customEquipment.toList(),
      durationMinutes: _customDurationMinutes,
    );
    _openWorkout(config);
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
        return 'All equipment';
      case Equipment.none:
        return 'Bodyweight';
    }
  }

  static String _configSubtitle(WorkoutConfiguration config) {
    final groups = config.muscleGroups.map(_muscleGroupDisplayName).join(', ');
    final equipment = config.equipment.contains(Equipment.all)
        ? 'All equipment'
        : config.equipment.map(_equipmentDisplayName).join(', ');
    return '$groups · $equipment · ${config.durationMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
      ),
      body: FutureBuilder<List<WorkoutConfiguration>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load workouts: ${snapshot.error}'));
          }

          final presets = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _CollapsibleSection(
                title: 'Create a workout',
                subtitle: 'Choose muscle groups and equipment, then generate a program',
                expanded: _createExpanded,
                onToggle: () => setState(() => _createExpanded = !_createExpanded),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Muscle groups',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Leave unselected to include any muscle group',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final group in MuscleGroup.values)
                            FilterChip(
                              label: Text(_muscleGroupDisplayName(group)),
                              selected: _customMuscleGroups.contains(group),
                              onSelected: (_) => _toggleCustomMuscleGroup(group),
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
                      const SizedBox(height: 4),
                      Text(
                        'Leave unselected to allow any equipment',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final equipment in _customEquipmentOptions)
                            FilterChip(
                              label: Text(_equipmentDisplayName(equipment)),
                              selected: _customEquipment.contains(equipment),
                              onSelected: (_) => _toggleCustomEquipment(equipment),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _customDurationMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final minutes in _durationOptions)
                            DropdownMenuItem(
                              value: minutes,
                              child: Text('$minutes minutes'),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _customDurationMinutes = value);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _generateCustomWorkout,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Generate workout'),
                      ),
                    ],
                  ),
                ),
              ),
              _CollapsibleSection(
                title: 'Preset dynamic workouts',
                subtitle: 'Ready-made programs that pick exercises for you',
                expanded: _presetsExpanded,
                onToggle: () => setState(() => _presetsExpanded = !_presetsExpanded),
                child: presets.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          'No presets found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < presets.length; i++) ...[
                            if (i > 0) const Divider(height: 1),
                            ListTile(
                              onTap: () => _openWorkout(presets[i]),
                              title: Text(presets[i].name),
                              subtitle: Text(_configSubtitle(presets[i])),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_arrow),
                                tooltip: 'Start workout',
                                onPressed: () => _openWorkout(presets[i]),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(title, style: theme.textTheme.titleMedium),
              subtitle: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              onTap: onToggle,
            ),
            AnimatedCrossFade(
              firstChild: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1),
                  child,
                ],
              ),
              secondChild: const SizedBox(width: double.infinity, height: 0),
              crossFadeState:
                  expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
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

          final workoutConfigs = snapshot.data ?? [];
          if (workoutConfigs.isEmpty) {
            return const Center(child: Text('No workouts found.'));
          }

          return ListView.separated(
            itemCount: workoutConfigs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final config = workoutConfigs[index];
              return ListTile(
                onTap: () => _openWorkout(config),
                title: Text(config.name),
                subtitle: Text('Duration: ${config.durationMinutes} minutes'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Open workout',
                  onPressed: () => _openWorkout(config),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

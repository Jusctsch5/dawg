import 'dart:convert';
import 'dart:io';

import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/configuration/workout_configuration.dart';
import 'package:dawg/ui/workout_page.dart';
import 'package:dawg/ui/workout_player_page.dart';
import 'package:dawg/workout/decoder.dart';
import 'package:dawg/workout/workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dynamic Audio Workout Generator (DAWG)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final log = Logger();
  late ExerciseConfiguration ec;

  Future<String> readFileFromBundle(String assetName) async {
    try {
      final String fileContents = await rootBundle.loadString(assetName);
      return fileContents;
    } catch (e) {
      // Handle any errors that might occur during file reading
      log.d('Error reading file: $e');
      return '';
    }
  }

  Future<List<WorkoutConfiguration>> _refreshWorkoutsAsync() async {
    log.d("_refreshWorkoutsAsync ");

    ec = await _refreshExerciseConfigsAsync();
    var workoutConfigs = await _refreshWorkoutConfigsAsync();
    return workoutConfigs;
  }

  Future<List<WorkoutConfiguration>> _refreshWorkoutConfigsAsync() async {
    log.d("Loading Workouts 1");

    var workoutJson = jsonDecode(await readFileFromBundle('assets/data/workout/workout_configuration.json'));
    log.d("Loading Workouts 2");
    var workouts = WorkoutConfiguration.getFromJsonList(workoutJson);
    log.d("Loading Workouts 3");
    for (var workout in workouts) {
      log.d("New Workout ${workout.name}");
    }

    return workouts;
  }

  Future<ExerciseConfiguration> _refreshExerciseConfigsAsync() async {
    log.d("_refreshExerciseConfigsAsync 1");

    final exConfigJson = jsonDecode(await rootBundle.loadString('assets/data/exercise/exercise_configuration.json'));
    log.d("_refreshExerciseConfigsAsync 2");

    var exConfig = ExerciseConfiguration.fromJson(exConfigJson);
    for (var exercise in exConfig.exercises) {
      log.d("New exercise ${exercise.name}");
    }

    log.d("New ExerciseConfig with exercises:${exConfig.exercises.length}");

    return exConfig;
  }

  Workout _processWorkoutConfig(WorkoutConfiguration wc) {
    var decoder = Decoder();
    var workout = decoder.generateWorkout(wc, ec);
    return workout;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkoutConfiguration>>(
      future: _refreshWorkoutsAsync(),
      builder: (context, AsyncSnapshot<List<WorkoutConfiguration>> snapshot) {
        if (!snapshot.hasData) {
          log.d("No snapshot data yet for workout configuration 1");
          return const CircularProgressIndicator();
        }
        var workoutConfigs = snapshot.data;
        if (workoutConfigs == null) {
          log.d("No snapshot data yet for workout configuration 2");
          return const CircularProgressIndicator();
        }

        // Build the main UI screen that renders the workouts
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: ListView(
              children: <Widget>[
                Scrollbar(
                  child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: workoutConfigs.length,
                  itemBuilder: (context, index) {
                    // Render the list of workouts.
                    return ListTile(
                      onTap: () {
                        log.d("TAPPED $index");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  WorkoutPage(title: workoutConfigs[index].name, workout: workoutConfigs[index])),
                        );
                      },
                      title: Text(workoutConfigs[index].name),
                      subtitle: Text("Duration: ${workoutConfigs[index].durationMinutes} Minutes"),
                      // Render the play button for each workout.
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Play Workout',
                        onPressed: () {
                          Workout workout = _processWorkoutConfig(workoutConfigs[index]);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutPlayerPage(workout: workout)),
                            );
                          }
                        )
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

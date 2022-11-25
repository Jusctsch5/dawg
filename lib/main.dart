import 'dart:convert';

import 'package:dawg/configuration/exercise_configuration.dart';
import 'package:dawg/configuration/workout_configuration.dart';
import 'package:dawg/ui/workout_page.dart';
import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/decoder.dart';
import 'package:dawg/workout/player.dart';
import 'package:dawg/workout/workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

void main() {
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
  final announcer = AnnouncerTts();
  final player = Player();

  Future<List<Workout>> _refreshWorkoutsAsync() async {
    List<Workout> workouts = [];

    var decoder = Decoder();

    final exConfigJson = jsonDecode(await rootBundle.loadString('assets/data/exercise/exercise_configuration.json'));
    var exConfig = ExerciseConfiguration.fromJson(exConfigJson);

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final workoutPaths = manifestMap.keys.where((String key) => key.contains('data/workout/')).toList();
    for (var workoutPath in workoutPaths) {
      log.d("Parsing new workout path $workoutPath");

      var workoutJson = jsonDecode(await rootBundle.loadString(workoutPath));
      var workoutConfig = WorkoutConfiguration.fromJson(workoutJson);
      var workout = decoder.generateWorkout(workoutConfig, exConfig);
      workouts.add(workout);
    }

    return workouts;
  }

  void _playWorkout(Workout workout) async {
    player.playWorkout(workout, announcer);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Workout>>(
        future: _refreshWorkoutsAsync(),
        builder: (context, AsyncSnapshot<List<Workout>> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            var workouts = snapshot.data;
            if (workouts == null) {
              return const CircularProgressIndicator();
            }

            return Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(widget.title),
              ),
              body: Center(
                child: ListView(
                  children: <Widget>[
                    Scrollbar(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: workouts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                onTap: () {
                                  log.d("TAPPED $index");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WorkoutPage(title: workouts[index].name, workout: workouts[index])),
                                  );
                                },
                                title: Text(workouts[index].name),
                                subtitle: Text("Duration: ${workouts[index].durationMinutes} Minutes"),
                                //trailing: Column(children: const [Icon(Icons.play_arrow)]));
                                trailing: IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    tooltip: 'Play Workout',
                                    onPressed: () {
                                      _playWorkout(workouts[index]);
                                    }));
                          }),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }
}

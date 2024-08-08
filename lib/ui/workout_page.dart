import 'package:dawg/configuration/workout_configuration.dart';
import 'package:dawg/workout/announcer.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final log = Logger();

class WorkoutOption extends StatefulWidget {
  WorkoutOption({Key? key, required this.workout, required this.optionName, required this.optionValue}) : super(key: key);

  WorkoutConfiguration workout;
  final String optionName;
  final String optionValue;

  @override
  State<WorkoutOption> createState() => _WorkoutOptionState();
}

class _WorkoutOptionState extends State<WorkoutOption> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(widget.optionName),
        subtitle: Center(
          child: TextField(
            onTap: () {
              log.d("Looking at workout option ${widget.optionName}");
            },
            decoration: InputDecoration(border: const OutlineInputBorder(), hintText: widget.optionValue),
          ),
        ));
    // trailing: IconButton(icon: const Icon(Icons.play_arrow), tooltip: 'Edit', onPressed: () {}));
  }
}

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key, required this.title, required this.workout}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final WorkoutConfiguration workout;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final log = Logger();
  final announcer = AnnouncerTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Scrollbar(
          child: ListView(children: <Widget>[
            WorkoutOption(workout: widget.workout, optionName: "name", optionValue: widget.workout.name),
            WorkoutOption(workout: widget.workout, optionName: "muscleGroups", optionValue: "groups"),
            WorkoutOption(
                workout: widget.workout, optionName: "startDelaySeconds", optionValue: widget.workout.startDelaySeconds.toString()),
            WorkoutOption(
                workout: widget.workout, optionName: "finishDelaySeconds", optionValue: widget.workout.finishDelaySeconds.toString()),
            WorkoutOption(workout: widget.workout, optionName: "durationMinutes", optionValue: widget.workout.durationMinutes.toString()),
          ]),
        ),
      ),
    );
  }
}

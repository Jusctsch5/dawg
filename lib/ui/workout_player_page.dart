import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/player.dart';
import 'package:dawg/workout/workout.dart';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final log = Logger();

class WorkoutPlayerPage extends StatefulWidget {
  WorkoutPlayerPage({Key? key, required this.workout}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Workout workout;
  final announcer = AnnouncerTts();
  final player = Player();

  @override
  State<WorkoutPlayerPage> createState() => _WorkoutPlayerPageState();
}

Future<void> _playWorkoutAsync(Workout workout, Player player, Announcer announcer) async {
  await player.playWorkout(workout, announcer);
}

class _WorkoutPlayerPageState extends State<WorkoutPlayerPage> {

  @override
  void initState() {
    super.initState();

    /*
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onAudioPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    var _isPlaying = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: () async {
          WakelockPlus.enable();
          _isPlaying = true;

          await widget.player.playWorkout(widget.workout, widget.announcer);
          _isPlaying = false;
          WakelockPlus.disable();
          }
        )
      );
    }

  @override
  void dispose() {
    super.dispose();
    // _audioPlayer.release();
    // _audioPlayer.dispose();
  }
}


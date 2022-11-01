
import 'dart:math';

import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/workout.dart';

class Player {

  Future playWorkout(Workout workout, Announcer announcer) async {
    await announcer.announce("Starting Workout: ${workout.name}");
    for (var exerciseW in workout.exercises) {
      await announcer.announce("Next Exercise: ${exerciseW.exercise.name}");
      await announcer.announce(exerciseW.exercise.description);
      await announcer.announceDelay(max(5, workout.config.startDelaySeconds-5));
      await announcer.announceCountdown(5);
      await announcer.announce("Starting Exercise: ${exerciseW.exercise.name}");

      for (var i=1; i <= exerciseW.sets; i++) {
        await announcer.announce("Set $i of ${exerciseW.sets}. Ready go!");
        await announcer.announceDelay(max(5, exerciseW.setDuration-5));
        await announcer.announceCountdown(5);
      }

      await announcer.announce("Finished Exercise: ${exerciseW.exercise.name}");
      await announcer.announce("Exercise cooldown for ${workout.config.startDelaySeconds} seconds");
    }

    await announcer.announce("Exercises for Workout: ${workout.name} Finished");
    await announcer.announce("Work it off for: ${workout.config.finishDelaySeconds} seconds");
    await announcer.announce("Finished Workout: ${workout.name}. Great Job.");
  }
}
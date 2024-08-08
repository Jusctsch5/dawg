import 'dart:math';

import 'package:dawg/workout/announcer.dart';
import 'package:dawg/workout/workout.dart';

class Player {
  /*
  The Workout Player object takes a workout and instructs the announcer on how to play it.
  The Player is also responsible for recording and manipulating the current state of the exercise
   */
  // final Workout workout;
  int position = 0;
  int duration = 0;

  // Player(this.workout);
  Player();

  Future playWorkout(Workout workout, Announcer announcer) async {
    await announcer.announce("Starting Workout: ${workout.name}");
    await announcer.announce("This workout will take approximately ${workout.durationMinutes} minutes ");
    for (var exerciseW in workout.exercises) {
      await announcer.announce("Next Exercise will be: ${exerciseW.exercise.name}");
      await announcer.announce(exerciseW.exercise.description);
      await announcer.announceDelay(max(5, workout.startDelaySeconds - 5));
      await announcer.announceCountdown(5);
      await announcer.announce("Starting Exercise: ${exerciseW.exercise.name}");

      for (var i = 1; i <= exerciseW.sets; i++) {
        if (i > 1) {
          await announcer.announce("Continuing Exercise: ${exerciseW.exercise.name}");
          if (exerciseW.exercise.alt) {
            await announcer.announce("Change sides");
          }
          await announcer.announceDelay(5);
          await announcer.announceCountdown(5); // add this as setting between exercises
        }

        await announcer.announce("Set $i of ${exerciseW.sets}. Ready go!");
        await announcer.announceDelay(max(5, exerciseW.setDuration - 5));
        await announcer.announceCountdown(5);
      }

      await announcer.announce("Finished Exercise: ${exerciseW.exercise.name}");
      await announcer.announce("Exercise cooldown for ${workout.startDelaySeconds} seconds");
    }

    await announcer.announce("Exercises for Workout: ${workout.name} Finished");
    await announcer.announce("Work it off for: ${workout.finishDelaySeconds} seconds");
    await announcer.announceDelay(max(5, workout.finishDelaySeconds - 5));
    await announcer.announceCountdown(5);
    await announcer.announce("Finished Workout: ${workout.name}. Great Job.");
  }
}

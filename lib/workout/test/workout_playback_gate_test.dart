import 'package:dawg/workout/workout_playback_gate.dart';
import 'package:test/test.dart';

void main() {
  group('WorkoutPlaybackGate', () {
    test('proceed waits while paused then continues on resume', () async {
      final gate = WorkoutPlaybackGate();
      gate.pause();

      final future = gate.proceed();
      var completed = false;
      future.then((value) => completed = true);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(completed, isFalse);

      gate.resume();
      expect(await future, isTrue);
    });

    test('cancel exits proceed loop', () async {
      final gate = WorkoutPlaybackGate();
      gate.cancel();
      expect(await gate.proceed(), isFalse);
    });
  });
}

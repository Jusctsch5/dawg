/// Shared cancel/pause control for workout playback and speech.
///
/// [Player] delay loops and [Announcer] speech chunks both call [proceed]
/// so cancel and (future) pause are handled in one place.
class WorkoutPlaybackGate {
  bool cancelled = false;
  bool paused = false;

  void cancel() {
    cancelled = true;
  }

  void pause() {
    paused = true;
  }

  void resume() {
    paused = false;
  }

  void reset() {
    cancelled = false;
    paused = false;
  }

  /// Returns false when cancelled. Waits while paused until resumed or cancelled.
  Future<bool> proceed() async {
    if (cancelled) return false;
    while (paused && !cancelled) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return !cancelled;
  }
}

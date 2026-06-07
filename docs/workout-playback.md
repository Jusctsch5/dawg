# Workout playback

How DAWG runs a workout: timing, speech, cancel, and the path toward pause.

## Layers

```text
UI (ActiveWorkoutPage)
    └── Player          workout script — exercises, sets, segments, timers
            └── Announcer   speech chunks + gate checks
                    └── PlatformSpeech / flutter_tts
    └── WorkoutPlaybackGate   shared cancel (and future pause)
    └── WorkoutPlaybackState  UI + wireframe progress
```

| Layer | Responsibility |
|-------|----------------|
| **Player** | What happens when: intro → exercise → sets → rest → finish |
| **Announcer** | How things are spoken; splits long text; honours gate |
| **WorkoutPlaybackGate** | Cancel now; pause/resume later — one flag both layers read |
| **WorkoutPlaybackState** | Snapshot for progress bar, wireframe, player bar |

## Duration estimation

[`WorkoutDurationEstimator`](../lib/workout/workout_duration_estimator.dart) mirrors [Player](../lib/workout/player.dart) timed segments (not TTS):

| Per exercise | Seconds |
|--------------|---------|
| Setup | `max(5, startDelay − 5) + 5` countdown |
| Each set | `max(5, setDuration − 5) + 5` countdown |
| Between sets | 5s delay + 5s countdown (sets 2+) |

Workout total = sum(exercise timed) + finish cooldown. [`Decoder`](../lib/workout/decoder.dart) uses the same formula when filling a preset to its target minutes (finish time reserved up front). `Workout.durationMinutes` is the **estimated** length after generation, not the preset target.

## WorkoutPlaybackGate

Single control object shared by `Player` and `Announcer`:

```dart
gate.cancel();   // stop workout
gate.pause();    // future: freeze timers + block new speech chunks
gate.resume();
gate.reset();    // at workout start

await gate.proceed();  // false if cancelled; waits while paused
```

**Player** calls `gate.proceed()` inside delay loops (`_runDelay`, countdown ticks).

**Announcer** calls `gate.proceed()` before and after each speech chunk.

## Sentence splitting

Long lines (especially exercise descriptions) are split on `.` into separate TTS utterances:

```dart
splitAnnouncerSentences(
  'Stand tall. Crunch down. Return with control.',
);
// → ['Stand tall.', 'Crunch down.', 'Return with control.']
```

Text **without** a period is one chunk (countdown digits, short cues):

```dart
splitAnnouncerSentences('Ready Go!'); // → ['Ready Go!']
```

Cancel can take effect **between sentences** without waiting for a full description to finish. Implementation: `lib/workout/announcer_sentence_split.dart`.

## Announcer contract

All announce methods return `Future<bool>`:

- `true` — completed
- `false` — cancelled (or paused-aborted when that is added)

```dart
if (!await announcer.announce(description)) return;
```

`Player` no longer checks a private `_cancelled` flag after every line — the announcer and gate handle it.

## Cancel flow

1. User leaves page or taps cancel → `gate.cancel()` (via `Player.cancel()`).
2. In-flight TTS may finish the current **chunk**; the next chunk sees `proceed() == false`.
3. Delay loops exit on the next 100ms tick.
4. `playWorkout` returns; UI shows finished/stopped state.

Future improvement: call `PlatformSpeech.stop()` on cancel for instant silence (watch Windows `flutter_tts` quirks).

## Pause (planned)

Gate supports `pause()` / `resume()`; UI pause button in the active workout player bar freezes timers, speech chunk boundaries, and wireframe animation.

Still optional later:

- Resume spoken cue (*"Resuming set 2"*)
- `PlatformSpeech.stop()` on pause for instant silence

## Game-style mental model

| Game concept | DAWG equivalent |
|--------------|-----------------|
| Simulation clock | `_runDelay` ticks + `gate.proceed()` |
| VO bus | `Announcer` + `PlatformSpeech` |
| Chunked dialogue | `splitAnnouncerSentences` |
| Pause menu | `gate.pause()` (UI not wired yet) |
| Prerendered clips | Future: cache exercise audio by ID |

See brainstorming in project chat: prerender vs split; split is implemented first.

## Key files

| File | Role |
|------|------|
| `lib/workout/player.dart` | Workout script |
| `lib/workout/announcer.dart` | Speech + chunk loop |
| `lib/workout/workout_playback_gate.dart` | Cancel/pause control |
| `lib/workout/announcer_sentence_split.dart` | Period splitting |
| `lib/workout/workout_playback_state.dart` | UI state |
| `lib/ui/active_workout_page.dart` | Creates shared gate, player, announcer |

## Tests

```bash
flutter test lib/workout/test/announcer_sentence_split_test.dart
flutter test lib/workout/test/announcer_test.dart
flutter test lib/workout/test/
```

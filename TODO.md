# TODO

## Infrastructure

- [ ] **GitHub Actions web deploy** — Add a workflow in `dawg/` that builds Flutter web (`flutter build web --base-href /dawg-web/`) and automatically publishes to the `dawg-web` repo (or `gh-pages`) on merge to main. This replaces the manual copy-into-`dawg_web`/commit/push workflow, which is stale and unmaintainable.

## TTS

- [x] **Unify cross-platform TTS with `flutter_tts`** — `FlutterTtsSpeech` wraps [`flutter_tts`](https://pub.dev/packages/flutter_tts) (^4.2.5) behind `PlatformSpeech` on all platforms. Windows builds need `nuget.exe` on PATH and `/await` in `windows/CMakeLists.txt` (flutter_tts WinRT coroutines; see issue #559).

## Wireframe

- [ ] Add wireframe animations for all exercises

## Backend

- [ ] We want to be able to store records of our exercises and workouts. Seems reasonable to just use local storage for now.

## Workout Player

- [x] Pause/resume button in active workout bar (`WorkoutPlaybackGate` + `isPaused` on playback state)
- [x] Sentence-split announcer + shared cancel gate
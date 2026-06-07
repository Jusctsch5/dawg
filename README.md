# DAWG - Dynamic Audio Workout Generator

A Flutter app that builds duration-based workouts and guides you through them with **spoken cues** and **animated wireframe demonstrations**.

Pick a preset or filter by muscle group and equipment, and DAWG assembles a multi-exercise session from a library of >50+ exercises. During a workout, a TTS announcer walks you through setup, set timing, rest periods, and side switches.

## Background

DAWG was originally written around the pandemic as a way to stay active and healthy. Specifically, it focused on resistance band workouts, which were otherwise hard to find workouts for. The handful of workouts got redundant quickly, (i.e. working the same muscles in the same order), so I wanted to add a dynamic element.

DAWG originally was a python application that used pyttsx3 to run the workouts. It was written to export to mp3 files for use in other environment, but the usability sufferred due to lack of a UI. Flutter was chosen as a single codebase for all platforms (windows, web, phone app, linux). 

## Features

| Area | What it does today |
|------|-------------------|
| **Workout generation** | JSON presets (`assets/data/workout/`) plus custom filters (muscle groups, equipment, duration) |
| **Exercise library** | Browse all exercises; run a quick 3×90s sample of any one |
| **Audio guidance** | Cross-platform TTS via [`flutter_tts`](https://pub.dev/packages/flutter_tts) behind `PlatformSpeech` |
| **Wireframe avatar** | Pseudo-3D stick-figure animations during active workouts (3 exercises animated so far) |
| **Active workout UI** | Live playback state, exercise wireframe, cancel/skip controls |

## Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| **Windows desktop** | Primary dev target | TTS via `flutter_tts`; build requires `nuget.exe` on PATH and `/await` compile flag (see `windows/CMakeLists.txt`) |
| **Web** | Supported | TTS via `flutter_tts`; deploy with `--base-href /dawg-web/` |
| **Android / iOS / macOS** | Supported | TTS via `flutter_tts` |

## Project layout

```
dawg/
├── assets/data/
│   ├── exercise/exercise_configuration.json   # Exercise definitions
│   └── workout/*.json                         # Workout presets
├── lib/
│   ├── configuration/   # JSON models for exercises & workouts
│   ├── data/            # Exercise repository
│   ├── ui/              # Pages + wireframe avatar
│   └── workout/         # Player, announcer, TTS, duration estimation
└── lib/ui/avatar/       # Wireframe renderer (see README there)
```

## Getting started

**Prerequisites:** [Flutter SDK](https://docs.flutter.dev/get-started/install) (SDK constraint: `>=2.17.6 <3.0.0`)

```bash
cd dawg
flutter pub get
flutter run              # default device
flutter run -d windows   # Windows desktop
flutter run -d chrome    # Web
```

## Running tests

Most tests are plain Dart/Flutter unit tests:

```bash
cd dawg
flutter test                                    # all tests
flutter test lib/workout/test/                  # workout engine
flutter test lib/ui/avatar/test/                # wireframe avatar
flutter test lib/configuration/test/            # JSON config parsing
```

**Interactive / manual test runners** (these are `main()` programs, not `flutter test`):

```bash
flutter run lib/workout/test/announcer_test.dart   # TTS announcer smoke test
flutter run lib/workout/test/player_test.dart      # full workout playback (AnnouncerTts vs AnnouncerLog)
```

**Wireframe projection debug** — dumps on-screen joint positions for all registered motions:

```bash
flutter test lib/ui/avatar/test/wireframe_projection_debug_test.dart --reporter expanded
```

See [`lib/ui/avatar/README.md`](lib/ui/avatar/README.md) for how to add exercise animations.

## Roadmap

Tracked in [`TODO.md`](TODO.md). Highlights:

- **TTS** — Unified cross-platform speech via `flutter_tts`
- **Infrastructure** — GitHub Actions web deploy (replace manual `dawg-web` copy/push)
- **Wireframe** — Animations for the remaining exercises
- **Storage** — Persist workout/exercise history locally

Ideas welcome — use this README and `TODO.md` as starting points for brainstorming.

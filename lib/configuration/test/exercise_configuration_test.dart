import 'package:dawg/common_defines.dart';
import 'package:test/test.dart';
import 'package:dawg/configuration/exercise_configuration.dart';
import 'dart:io';
import 'dart:convert';

void testSimpleConfigurationFromJson() {
  Map<String, dynamic> data = {
    "exercises": [
      {
        "name": "High Standing Crunch",
        "description": "Using high suspended bands from standing position, back to the wall, bring ribcage down, incidentally pulling the bands down",
        "id": "7755798c-647c-45c3-9c05-a434699c68bc",
        "equipment": ["suspendedBand"],
        "alternateSidesBetweenSets": true,
        "muscleGroups": ["abdominals"],
        "muscles": ["abs", "obliques"]
      },
      {
        "name": "Curl to Front Squat",
        "description": "Standing up straight with arms at sides, holding bands. Hook bands on feet. Perform a dumbell curl and squat down, keeping back straight.",
        "id": "598ae548-4fca-445b-a5d1-1a64b0ffe3ab",
        "equipment": ["resistanceBand"],
        "muscleGroups": ["legs", "arms"],
        "muscles": ["glutes", "hipflexors", "quads", "abs", "calves", "biceps"]
      }
    ]
  };

  var configuration = ExerciseConfiguration.fromJson(data);
  expect(configuration.exercises[0].name, "High Standing Crunch");
}

Future<void> testSimpleConfigurationFromFile() async {
  var file = File('lib/configuration/test/exercise_configuration.json');
  var json = jsonDecode(await file.readAsString());
  var configuration = ExerciseConfiguration.fromJson(json);
  expect(configuration.exercises[0].name, "High Standing Crunch");
}

Future<void> testFilterExercises() async {
  var file = File('lib/configuration/test/exercise_configuration.json');
  var json = jsonDecode(await file.readAsString());
  var configuration = ExerciseConfiguration.fromJson(json);
  var filter = ExerciseFilter();
  var exercises = configuration.filterExercises(filter);
  expect(exercises.length, configuration.exercises.length);

  filter = ExerciseFilter(equipment: Equipment.ring);
  exercises = configuration.filterExercises(filter);
  expect(exercises.length, 8);

  filter = ExerciseFilter(equipment: Equipment.resistanceBand);
  exercises = configuration.filterExercises(filter);
  expect(exercises.length, 24);

  filter = ExerciseFilter(equipment: Equipment.resistanceBand, muscleGroup: MuscleGroup.arms);
  exercises = configuration.filterExercises(filter);
  expect(exercises.length, 13);

  filter = ExerciseFilter(equipment: Equipment.resistanceBand, muscleGroup: MuscleGroup.arms, muscle: Muscle.triceps);
  exercises = configuration.filterExercises(filter);
  expect(exercises.length, 5);
}

Future<void> testFilterExerciseByGroups() async {
  var file = File('lib/configuration/test/exercise_configuration.json');
  var json = jsonDecode(await file.readAsString());
  var configuration = ExerciseConfiguration.fromJson(json);
  var filter = ExerciseFilterByGroups();
  var exercises = configuration.filterExercisesByGroups(filter);
  expect(exercises.length, configuration.exercises.length);

  filter = ExerciseFilterByGroups(equipment: [Equipment.ring]);
  exercises = configuration.filterExercisesByGroups(filter);
  expect(exercises.length, 8);

  filter = ExerciseFilterByGroups(equipment: [Equipment.ring, Equipment.resistanceBand]);
  exercises = configuration.filterExercisesByGroups(filter);
  expect(exercises.length, 28);

  filter = ExerciseFilterByGroups(equipment: [Equipment.ring, Equipment.resistanceBand], muscleGroups: [MuscleGroup.arms]);
  exercises = configuration.filterExercisesByGroups(filter);
  expect(exercises.length, 17);

  filter = ExerciseFilterByGroups(equipment: [Equipment.ring, Equipment.resistanceBand], muscleGroups: [MuscleGroup.arms], muscle: Muscle.triceps);
  exercises = configuration.filterExercisesByGroups(filter);
  expect(exercises.length, 6);

  // Plank and pushup
  filter = ExerciseFilterByGroups(equipment: [Equipment.gluteBand], muscleGroups: [MuscleGroup.arms]);
  exercises = configuration.filterExercisesByGroups(filter);
  expect(exercises.length, 2);
}

void main() {
  group("ExerciseConfiguration", () {
    test("testSimpleConfigurationFromJson", () {
      testSimpleConfigurationFromJson();
    });

    test("testSimpleConfigurationFromFile", () async {
      await testSimpleConfigurationFromFile();
    });

    test("testFilterExercises", () async {
      await testFilterExercises();
    });

    test("testFilterExercisesByGroups", () async {
      await testFilterExerciseByGroups();
    });
  });
}

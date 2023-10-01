import 'package:test/test.dart';
import 'package:dawg/configuration/workout_configuration.dart';
import 'dart:io';
import 'dart:convert';

void testSimpleConfigurationFromJson() {
  Map<String, dynamic> data = {
    "name": "Dynamic Abs Workout",
    "muscleGroups": ["abdominals"],
    "durationMinutes": 20,
    "equipment": ["resistanceBand", "gluteBand", "ring"],
    "startDelaySeconds": 20,
    "finishDelaySeconds": 60
  };
  var configuration = WorkoutConfiguration.fromJson(data);
  expect(configuration.startDelaySeconds, 20);
}

Future<void> testSimpleConfigurationFromFile() async {
  var file = File('lib/configuration/test/workout_configuration.json');
  var json = jsonDecode(await file.readAsString());
  var configuration = WorkoutConfiguration.fromJson(json);
  expect(configuration.startDelaySeconds, 30);
}

void main() {
  group("WorkoutConfiguration", () {
    test("testSimpleConfigurationFromJson", () {
      testSimpleConfigurationFromJson();
    });
    test("testSimpleConfiguration2", () async {
      await testSimpleConfigurationFromFile();
    });
  });
}

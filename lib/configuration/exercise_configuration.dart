import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

import '../common_defines.dart';

@JsonSerializable()
class Exercise {
  String name;
  String description;
  List<Equipment> equipment;
  List<MuscleGroup> muscleGroups;
  List<Muscle> muscles;
  bool alt;

  // Constructor, with syntactic sugar for assignment to members.
  Exercise(
      {required this.name,
      required this.description,
      required this.equipment,
      required this.muscleGroups,
      required this.muscles,
      required this.alt});

  // Named Constructor
  Exercise.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        equipment = json.containsKey('equipment')
            ? List<Equipment>.from(json['equipment'].map((x) => Equipment.values.byName(x)).toList())
            : [Equipment.none],
        muscleGroups = List<MuscleGroup>.from(json['muscleGroups'].map((x) => MuscleGroup.values.byName(x)).toList()),
        muscles = List<Muscle>.from(json['muscles'].map((x) => Muscle.values.byName(x)).toList()),
        alt = json.containsKey('alternateSidesBetweenSets') ? json['alternateSidesBetweenSets'] : false;
}

@JsonSerializable()
class ExerciseConfiguration {
  List<Exercise> exercises;
  final log = Logger(level: Level.info);

  // Constructor, with syntactic sugar for assignment to members.
  ExerciseConfiguration({required this.exercises});

  // Named Constructor
  ExerciseConfiguration.fromJson(Map<String, dynamic> json)
      : exercises = List<Exercise>.from(json['exercises'].map((x) => Exercise.fromJson(x)));

  List<Exercise> filterExercises(ExerciseFilter filter) {
    List<Exercise> exercises = [];

    for (var exercise in this.exercises) {
      bool match = true;

      if (filter.equipment != null) {
        if (!exercise.equipment.contains(filter.equipment) && !exercise.equipment.contains(Equipment.none)) {
          match = false;
          continue;
        }
      }

      if (filter.muscleGroup != null) {
        if (!exercise.muscleGroups.contains(filter.muscleGroup)) {
          match = false;
          continue;
        }
      }

      if (filter.muscle != null) {
        if (!exercise.muscles.contains(filter.muscle)) {
          match = false;
          continue;
        }
      }

      if (match) {
        exercises.add(exercise);
      }
    }

    return exercises;
  }

  List<Exercise> filterExercisesByGroups(ExerciseFilterByGroups filter) {
    /// From provided filter, look at all possible options for a match.
    /// Could be muscles, muscleGroups, or equipment.
    List<Exercise> exercises = [];
    var filterEquip = filter.equipment ?? [];
    if (filterEquip.contains(Equipment.all)) {
      filterEquip.clear();
      filterEquip.addAll([Equipment.gluteBand, Equipment.resistanceBand, Equipment.suspendedBand, Equipment.ring]);
    }

    var filterGroups = filter.muscleGroups ?? [];

    for (var exercise in this.exercises) {
      bool match = true;

      // Determine if the equipment matches.
      // If not, bail.
      if (filterEquip.isNotEmpty) {
        match = false;
        for (var equipment in filterEquip) {
          if (exercise.equipment.contains(equipment) || exercise.equipment.contains(Equipment.none)) {
            match = true;
            continue;
          }
        }
        if (match == false) {
          log.v("No match exercise:${exercise.name} due to equipment (has:${exercise.equipment}, ask:$filterEquip");
          continue;
        }
      }

      if (match == true && filterGroups.isNotEmpty) {
        match = false;
        for (var group in filterGroups) {
          if (exercise.muscleGroups.contains(group)) {
            log.d("MATCH exercise:${exercise.name} due to group (has:${exercise.muscleGroups}, ask:$filterGroups");
            match = true;
            continue;
          }
        }
        if (match == false) {
          log.v("NOMATCH exercise:${exercise.name} due to group (has:${exercise.muscleGroups}, ask:$filterGroups");
          continue;
        }
      }

      if (match == true && filter.muscle != null) {
        match = false;
        if (!exercise.muscles.contains(filter.muscle)) {
          log.v("NOMATCH exercise:${exercise.name} due to muscle (has:${exercise.muscles}, ask:${filter.muscle}");
          match = false;
          continue;
        }

        log.d("MATCH exercise:${exercise.name} due to muscle (has:${exercise.muscles}, ask:${filter.muscle}");
        match = true;
      }

      if (match) {
        log.d("Add exercise:${exercise.name}");
        exercises.add(exercise);
      }
    }

    return exercises;
  }
}

class ExerciseFilter {
  // Match this equipment or none
  Equipment? equipment;
  MuscleGroup? muscleGroup;
  Muscle? muscle;

  ExerciseFilter({this.equipment, this.muscleGroup, this.muscle});
}

class ExerciseFilterByGroups {
  // OR filtering - Match this equipment or none
  List<Equipment>? equipment;
  List<MuscleGroup>? muscleGroups;
  Muscle? muscle;

  ExerciseFilterByGroups({this.equipment, this.muscleGroups, this.muscle});
}

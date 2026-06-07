import 'package:json_annotation/json_annotation.dart';

import '../common_defines.dart';

@JsonSerializable()
class WorkoutConfiguration {
  String name;
  List<MuscleGroup> muscleGroups;
  int durationMinutes;
  int durationSeconds;
  List<Equipment> equipment;
  int startDelaySeconds;
  int finishDelaySeconds;
  int setDurationSeconds;
  int setPerExercise;

  // Constructor, with syntactic sugar for assignment to members.
  WorkoutConfiguration(
      {required this.name,
      required this.muscleGroups,
      required this.durationMinutes,
      required this.durationSeconds,
      required this.equipment,
      required this.startDelaySeconds,
      required this.finishDelaySeconds,
      required this.setDurationSeconds,
      required this.setPerExercise});

  // Named Constructor
  WorkoutConfiguration.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        muscleGroups =
          json.containsKey('muscleGroups') ?
          List<MuscleGroup>.from(json['muscleGroups'].map((x) => MuscleGroup.values.byName(x)).toList()) :
          [MuscleGroup.abdominals, MuscleGroup.arms, MuscleGroup.legs],
        durationMinutes = json['durationMinutes'],
        durationSeconds = json['durationMinutes'] * 60,
        equipment =
          json.containsKey('equipment') ?
          List<Equipment>.from(json['equipment'].map((x) => Equipment.values.byName(x)).toList()) :
          [Equipment.none],
        startDelaySeconds =
          json.containsKey('startDelaySeconds') ?
          json['startDelaySeconds'] :
          30,
        finishDelaySeconds =
        json.containsKey('finishDelaySeconds') ?
          json['finishDelaySeconds'] :
          30,
        setDurationSeconds = json.containsKey('setDurationSeconds') ?
          json['setDurationSeconds'] :
          30,
        setPerExercise = json.containsKey('setPerExercise') ?
          json['setPerExercise'] :
          3;

  /// Builds a one-off workout config from user-selected filters.
  factory WorkoutConfiguration.custom({
    List<MuscleGroup> muscleGroups = const [],
    List<Equipment> equipment = const [],
    int durationMinutes = 20,
    int startDelaySeconds = 30,
    int finishDelaySeconds = 30,
    int setDurationSeconds = 30,
    int setPerExercise = 3,
  }) {
    final resolvedGroups = muscleGroups.isEmpty
        ? [MuscleGroup.abdominals, MuscleGroup.arms, MuscleGroup.legs]
        : muscleGroups;
    final groupLabel = muscleGroups.isEmpty
        ? 'any'
        : resolvedGroups.map((g) => g.name).join(', ');
    return WorkoutConfiguration(
      name: 'Custom ($groupLabel)',
      muscleGroups: resolvedGroups,
      durationMinutes: durationMinutes,
      durationSeconds: durationMinutes * 60,
      equipment: equipment.isEmpty ? [Equipment.all] : equipment,
      startDelaySeconds: startDelaySeconds,
      finishDelaySeconds: finishDelaySeconds,
      setDurationSeconds: setDurationSeconds,
      setPerExercise: setPerExercise,
    );
  }
}

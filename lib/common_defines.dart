import 'package:json_annotation/json_annotation.dart';

enum MuscleGroup {
  @JsonValue("abdominals")
  abdominals,
  @JsonValue("arms")
  arms,
  @JsonValue("legs")
  legs,
}

enum Equipment {
  @JsonValue("suspendedBand")
  suspendedBand,
  @JsonValue("resistanceBand")
  resistanceBand,
  @JsonValue("gluteBand")
  gluteBand,
  @JsonValue("ring")
  ring,
  @JsonValue("dumbbell")
  dumbbell,
  @JsonValue("all")
  all,
  @JsonValue("none")
  none
}

enum ArmMuscles {
  @JsonValue("biceps")
  biceps,
  @JsonValue("triceps")
  triceps,
  @JsonValue("deltoids")
  deltoids,
  @JsonValue("rotatorcuff")
  rotatorcuff,
  @JsonValue("traps")
  traps,
}

enum AbMuscles {
  @JsonValue("pecs")
  pecs,
  @JsonValue("abs")
  abs,
  @JsonValue("obliques")
  obliques,
}

enum LegMuscles {
  @JsonValue("adductor")
  adductor,
  @JsonValue("glutes")
  glutes,
  @JsonValue("hipflexors")
  hipflexors,
  @JsonValue("quads")
  quads,
  @JsonValue("calves")
  calves,
  @JsonValue("hamstrings")
  hamstrings,
}

enum Muscle {
  @JsonValue("biceps")
  biceps,
  @JsonValue("triceps")
  triceps,
  @JsonValue("deltoids")
  deltoids,
  @JsonValue("rotatorcuff")
  rotatorcuff,
  @JsonValue("traps")
  traps,

  @JsonValue("pecs")
  pecs,
  @JsonValue("abs")
  abs,
  @JsonValue("obliques")
  obliques,
  @JsonValue("back")
  back,
  @JsonValue("adductor")
  adductor,
  @JsonValue("glutes")
  glutes,
  @JsonValue("hipflexors")
  hipflexors,
  @JsonValue("quads")
  quads,
  @JsonValue("calves")
  calves,
  @JsonValue("hamstrings")
  hamstrings,
}

List<Muscle> getMusclesForGroups(List<MuscleGroup> groups) {
  List<Muscle> muscles = [];
  if (groups.contains(MuscleGroup.legs)) {
    var legMuscles = [Muscle.adductor, Muscle.glutes, Muscle.hipflexors, Muscle.quads, Muscle.calves, Muscle.hamstrings];
    muscles.addAll(legMuscles);
  }

  if (groups.contains(MuscleGroup.abdominals)) {
    var abMuscles = [Muscle.pecs, Muscle.abs, Muscle.obliques];
    muscles.addAll(abMuscles);
  }

  if (groups.contains(MuscleGroup.arms)) {
    var armMuscles = [Muscle.biceps, Muscle.triceps, Muscle.deltoids, Muscle.rotatorcuff, Muscle.traps];
    muscles.addAll(armMuscles);
  }

  return muscles;
}

import 'package:dawg/common_defines.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:flutter/material.dart';

/// Colors and styling for exercise equipment in wireframe demos.
class WireframeEquipment {
  WireframeEquipment._();

  /// Resistance tube band — red.
  static const resistanceBandColor = Color(0xFFE53935);

  /// Door / anchor suspended handles — teal.
  static const suspendedBandColor = Color(0xFF00897B);

  /// Isometric ring — amber.
  static const ringColor = Color(0xFFF9A825);

  /// Dumbbells / free weights — blue-gray steel.
  static const freeWeightColor = Color(0xFF546E7A);

  static Color colorFor(Equipment equipment) {
    switch (equipment) {
      case Equipment.resistanceBand:
        return resistanceBandColor;
      case Equipment.suspendedBand:
        return suspendedBandColor;
      case Equipment.ring:
        return ringColor;
      case Equipment.freeWeight:
        return freeWeightColor;
      case Equipment.gluteBand:
      case Equipment.all:
      case Equipment.none:
        return resistanceBandColor;
    }
  }

  static double strokeScaleFor(Equipment equipment) {
    switch (equipment) {
      case Equipment.ring:
        return 1.45;
      case Equipment.freeWeight:
        return 1.25;
      case Equipment.resistanceBand:
      case Equipment.suspendedBand:
        return 1.35;
      case Equipment.gluteBand:
      case Equipment.all:
      case Equipment.none:
        return 1.2;
    }
  }

  static bool isResistanceBandBone(WireframeBone bone) {
    return (bone.from == 'gripFL' && bone.to == 'gripFR') ||
        (bone.from == 'wristL' && bone.to == 'wristR');
  }

  static bool isEquipmentJoint(String jointId) {
    return jointId.startsWith('eq');
  }

  static bool isWeightPlateJoint(String jointId) {
    return jointId.startsWith('eqWeightPlate');
  }

  /// Returns the equipment type responsible for [bone], if any.
  static Equipment? equipmentForBone(WireframeBone bone, List<Equipment> active) {
    if (active.contains(Equipment.resistanceBand) && isResistanceBandBone(bone)) {
      return Equipment.resistanceBand;
    }
    if (_boneUsesPrefix(bone, 'eqSusp') && active.contains(Equipment.suspendedBand)) {
      return Equipment.suspendedBand;
    }
    if (_boneUsesPrefix(bone, 'eqRing') && active.contains(Equipment.ring)) {
      return Equipment.ring;
    }
    if (_boneUsesPrefix(bone, 'eqWeight') && active.contains(Equipment.freeWeight)) {
      return Equipment.freeWeight;
    }
    return null;
  }

  static bool _boneUsesPrefix(WireframeBone bone, String prefix) {
    return bone.from.startsWith(prefix) || bone.to.startsWith(prefix);
  }
}

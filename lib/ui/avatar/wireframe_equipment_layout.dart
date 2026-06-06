import 'dart:math' as math;
import 'dart:ui';

import 'package:dawg/common_defines.dart';
import 'package:dawg/ui/avatar/body_pose_builder_3d.dart';
import 'package:dawg/ui/avatar/wireframe_figure.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:dawg/ui/avatar/wireframe_pose_3d.dart';

/// Adds equipment joints and bones to figure poses for wireframe rendering.
class WireframeEquipmentLayout {
  static WireframeFigurePose augmentFigure(
    WireframeFigurePose pose,
    List<Equipment> equipment,
  ) {
    if (!_hasRenderableEquipment(equipment)) return pose;

    if (pose is ProjectedWireframeFigurePose) {
      return ProjectedWireframeFigurePose(augment3d(pose.pose, equipment));
    }
    if (pose is FlatWireframeFigurePose) {
      return FlatWireframeFigurePose(augment2d(pose.pose, equipment));
    }
    return pose;
  }

  static bool _hasRenderableEquipment(List<Equipment> equipment) {
    if (equipment.isEmpty) return false;
    return equipment.any((e) =>
        e == Equipment.resistanceBand ||
        e == Equipment.suspendedBand ||
        e == Equipment.ring ||
        e == Equipment.freeWeight);
  }

  static WireframePose3d augment3d(WireframePose3d pose, List<Equipment> equipment) {
    if (!_hasRenderableEquipment(equipment)) return pose;

    final joints = Map<String, WireframeVec3>.from(pose.joints);
    final bones = List<WireframeBone>.from(pose.bones);
    final addedBoneKeys = <String>{};

    void addBone(String from, String to) {
      final key = '$from|$to';
      if (addedBoneKeys.contains(key)) return;
      addedBoneKeys.add(key);
      bones.add(WireframeBone(from, to));
    }

    for (final item in equipment) {
      switch (item) {
        case Equipment.resistanceBand:
          if (_hasJointPair(joints, 'gripFL', 'gripFR')) {
            addBone('gripFL', 'gripFR');
          }
          break;
        case Equipment.suspendedBand:
          _addSuspendedBand3d(joints, addBone);
          break;
        case Equipment.ring:
          _addRing3d(joints, addBone);
          break;
        case Equipment.freeWeight:
          _addFreeWeights3d(joints, addBone);
          break;
        case Equipment.gluteBand:
        case Equipment.all:
        case Equipment.none:
          break;
      }
    }

    return WireframePose3d(
      id: pose.id,
      label: pose.label,
      joints: joints,
      bones: bones,
      headJoint: pose.headJoint,
    );
  }

  static WireframePose augment2d(WireframePose pose, List<Equipment> equipment) {
    if (!_hasRenderableEquipment(equipment)) return pose;

    final joints = Map<String, Offset>.from(pose.joints);
    final bones = List<WireframeBone>.from(pose.bones);
    final addedBoneKeys = <String>{};

    void addBone(String from, String to) {
      final key = '$from|$to';
      if (addedBoneKeys.contains(key)) return;
      addedBoneKeys.add(key);
      bones.add(WireframeBone(from, to));
    }

    for (final item in equipment) {
      switch (item) {
        case Equipment.resistanceBand:
          if (_hasJointPair2d(joints, 'wristL', 'wristR')) {
            addBone('wristL', 'wristR');
          }
          break;
        case Equipment.suspendedBand:
          _addSuspendedBand2d(joints, addBone);
          break;
        case Equipment.ring:
          _addRing2d(joints, addBone);
          break;
        case Equipment.freeWeight:
          _addFreeWeights2d(joints, addBone);
          break;
        case Equipment.gluteBand:
        case Equipment.all:
        case Equipment.none:
          break;
      }
    }

    return WireframePose(
      id: pose.id,
      label: pose.label,
      joints: joints,
      bones: bones,
      headJoint: pose.headJoint,
    );
  }

  static void _addSuspendedBand3d(
    Map<String, WireframeVec3> joints,
    void Function(String from, String to) addBone,
  ) {
    for (final side in ['L', 'R']) {
      final handId = joints.containsKey('gripF$side')
          ? 'gripF$side'
          : joints.containsKey('wristF$side')
              ? 'wristF$side'
              : null;
      if (handId == null) continue;
      final hand = joints[handId]!;

      final anchorId = 'eqSuspAnchorF$side';
      joints[anchorId] = WireframeVec3(hand.x, 1.06, hand.z - 0.22);
      addBone(anchorId, handId);
    }

    if (joints.containsKey('eqSuspAnchorFL') && joints.containsKey('eqSuspAnchorFR')) {
      addBone('eqSuspAnchorFL', 'eqSuspAnchorFR');
    }
  }

  static void _addSuspendedBand2d(
    Map<String, Offset> joints,
    void Function(String from, String to) addBone,
  ) {
    for (final side in ['L', 'R']) {
      final wrist = joints['wrist$side'];
      if (wrist == null) continue;

      final anchorId = 'eqSuspAnchor$side';
      joints[anchorId] = Offset(wrist.dx, 0.02);
      addBone(anchorId, 'wrist$side');
    }

    if (joints.containsKey('eqSuspAnchorL') && joints.containsKey('eqSuspAnchorR')) {
      addBone('eqSuspAnchorL', 'eqSuspAnchorR');
    }
  }

  static void _addRing3d(
    Map<String, WireframeVec3> joints,
    void Function(String from, String to) addBone,
  ) {
    final left = joints['gripFL'] ?? joints['wristFL'];
    final right = joints['gripFR'] ?? joints['wristFR'];
    if (left == null || right == null) return;

    final center = BodyPoseBuilder3d.mid(left, right);
    // Horizontal ring (XZ plane, constant Y). Grips sit on two opposite points
    // of the loop; compressing the press drives those two points together.
    final radiusX = math.max((right.x - left.x).abs() / 2, 0.03);
    final radiusZ = math.max((right.z - left.z).abs() / 2, 0.04);
    const segments = 8;
    const squeezeIndexRight = 0;
    const squeezeIndexLeft = 4;
    final ringIds = <String>[];

    for (var i = 0; i < segments; i++) {
      final id = 'eqRing$i';
      if (i == squeezeIndexRight) {
        joints[id] = right;
      } else if (i == squeezeIndexLeft) {
        joints[id] = left;
      } else {
        final angle = (i / segments) * math.pi * 2;
        joints[id] = WireframeVec3(
          center.x + math.cos(angle) * radiusX,
          center.y,
          center.z + math.sin(angle) * radiusZ,
        );
      }
      ringIds.add(id);
    }

    for (var i = 0; i < segments; i++) {
      addBone(ringIds[i], ringIds[(i + 1) % segments]);
    }
  }

  static void _addRing2d(
    Map<String, Offset> joints,
    void Function(String from, String to) addBone,
  ) {
    final left = joints['wristL'];
    final right = joints['wristR'];
    if (left == null || right == null) return;

    final center = Offset((left.dx + right.dx) / 2, (left.dy + right.dy) / 2);
    final radiusX = math.max((right.dx - left.dx).abs() / 2, 0.03);
    const radiusY = 0.04;
    const segments = 8;
    const squeezeIndexRight = 0;
    const squeezeIndexLeft = 4;
    final ringIds = <String>[];

    for (var i = 0; i < segments; i++) {
      final id = 'eqRing$i';
      if (i == squeezeIndexRight) {
        joints[id] = right;
      } else if (i == squeezeIndexLeft) {
        joints[id] = left;
      } else {
        final angle = (i / segments) * math.pi * 2;
        joints[id] = Offset(
          center.dx + math.cos(angle) * radiusX,
          center.dy + math.sin(angle) * radiusY,
        );
      }
      ringIds.add(id);
    }

    for (var i = 0; i < segments; i++) {
      addBone(ringIds[i], ringIds[(i + 1) % segments]);
    }
  }

  static void _addFreeWeights3d(
    Map<String, WireframeVec3> joints,
    void Function(String from, String to) addBone,
  ) {
    for (final side in ['L', 'R']) {
      final handId = joints.containsKey('gripF$side')
          ? 'gripF$side'
          : joints.containsKey('wristF$side')
              ? 'wristF$side'
              : null;
      if (handId == null) continue;
      final grip = joints[handId]!;
      final elbow = joints['elbowF$side'];

      final axis = _unit3d(_sub3d(grip, elbow ?? WireframeVec3(grip.x, grip.y - 0.1, grip.z)));
      const halfSpan = 0.055;

      final outId = 'eqWeightOutF$side';
      final inId = 'eqWeightInF$side';

      joints[outId] = _add3d(grip, _scale3d(axis, halfSpan));
      joints[inId] = _add3d(grip, _scale3d(axis, -halfSpan));
      joints['eqWeightPlateOutF$side'] = joints[outId]!;
      joints['eqWeightPlateInF$side'] = joints[inId]!;

      addBone(outId, inId);
      addBone(handId, outId);
    }
  }

  static void _addFreeWeights2d(
    Map<String, Offset> joints,
    void Function(String from, String to) addBone,
  ) {
    for (final side in ['L', 'R']) {
      final wrist = joints['wrist$side'];
      final elbow = joints['elbow$side'];
      if (wrist == null) continue;

      final axis = _unit2d(_sub2d(wrist, elbow ?? Offset(wrist.dx, wrist.dy + 0.1)));
      const halfSpan = 0.035;

      final outId = 'eqWeightOut$side';
      final inId = 'eqWeightIn$side';
      joints[outId] = _add2d(wrist, _scale2d(axis, halfSpan));
      joints[inId] = _add2d(wrist, _scale2d(axis, -halfSpan));
      joints['eqWeightPlateOut$side'] = joints[outId]!;
      joints['eqWeightPlateIn$side'] = joints[inId]!;

      addBone(outId, inId);
      addBone('wrist$side', outId);
    }
  }

  static bool _hasJointPair(Map<String, WireframeVec3> joints, String a, String b) {
    return joints.containsKey(a) && joints.containsKey(b);
  }

  static bool _hasJointPair2d(Map<String, Offset> joints, String a, String b) {
    return joints.containsKey(a) && joints.containsKey(b);
  }

  static WireframeVec3 _sub3d(WireframeVec3 a, WireframeVec3 b) {
    return WireframeVec3(a.x - b.x, a.y - b.y, a.z - b.z);
  }

  static WireframeVec3 _add3d(WireframeVec3 a, WireframeVec3 b) {
    return WireframeVec3(a.x + b.x, a.y + b.y, a.z + b.z);
  }

  static WireframeVec3 _scale3d(WireframeVec3 v, double s) {
    return WireframeVec3(v.x * s, v.y * s, v.z * s);
  }

  static WireframeVec3 _unit3d(WireframeVec3 v) {
    final len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    if (len < 1e-9) return const WireframeVec3(0, -1, 0);
    return WireframeVec3(v.x / len, v.y / len, v.z / len);
  }

  static Offset _sub2d(Offset a, Offset b) => Offset(a.dx - b.dx, a.dy - b.dy);

  static Offset _add2d(Offset a, Offset b) => Offset(a.dx + b.dx, a.dy + b.dy);

  static Offset _scale2d(Offset v, double s) => Offset(v.dx * s, v.dy * s);

  static Offset _unit2d(Offset v) {
    final len = math.sqrt(v.dx * v.dx + v.dy * v.dy);
    if (len < 1e-9) return const Offset(0, 1);
    return Offset(v.dx / len, v.dy / len);
  }
}

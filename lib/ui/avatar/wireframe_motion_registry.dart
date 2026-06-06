import 'dart:ui';

import 'package:dawg/ui/avatar/wireframe_figure.dart';
import 'package:dawg/ui/avatar/wireframe_grip_motion.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:dawg/ui/avatar/wireframe_pose_3d.dart';

/// Central registry of wireframe motions — add exercises here, not new motion classes.
class WireframeMotionRegistry {
  static const pullAparts3d = GripMotionSpec3d(
    id: 'pull_aparts_3d',
    label: 'Pull aparts (3D)',
    leftGripStart: WireframeVec3(-0.11, 0.80, 0.80),
    rightGripStart: WireframeVec3(0.11, 0.80, 0.80),
    leftGripEnd: WireframeVec3(-0.90, 0.80, 0.12),
    rightGripEnd: WireframeVec3(0.90, 0.80, 0.12),
  );

  static const ringPress3d = GripMotionSpec3d(
    id: 'ring_press_3d',
    label: 'Ring press (3D)',
    leftElbow: WireframeVec3(-0.22, 0.70, 0.30),
    rightElbow: WireframeVec3(0.22, 0.70, 0.30),
    leftGripStart: WireframeVec3(-0.32, 0.58, 0.34),
    rightGripStart: WireframeVec3(0.32, 0.58, 0.34),
    leftGripEnd: WireframeVec3(-0.08, 0.58, 0.34),
    rightGripEnd: WireframeVec3(0.08, 0.58, 0.34),
  );

  static const overheadRingPress3d = GripMotionSpec3d(
    id: 'overhead_ring_press_3d',
    label: 'Overhead ring press (3D)',
    leftElbow: WireframeVec3(-0.20, 0.96, 0.16),
    rightElbow: WireframeVec3(0.20, 0.96, 0.16),
    leftGripStart: WireframeVec3(-0.30, 0.90, 0.18),
    rightGripStart: WireframeVec3(0.30, 0.90, 0.18),
    leftGripEnd: WireframeVec3(-0.08, 0.90, 0.18),
    rightGripEnd: WireframeVec3(0.08, 0.90, 0.18),
  );

  static const pullAparts2d = GripMotionSpec2d(
    id: 'pull_aparts',
    label: 'Pull aparts',
    extraBones: [WireframeBone('wristL', 'wristR')],
    jointsStart: {
      'elbowL': Offset(0.43, 0.20),
      'elbowR': Offset(0.57, 0.20),
      'wristL': Offset(0.49, 0.20),
      'wristR': Offset(0.51, 0.20),
    },
    jointsEnd: {
      'elbowL': Offset(-0.04, 0.20),
      'elbowR': Offset(1.04, 0.20),
      'wristL': Offset(-0.42, 0.20),
      'wristR': Offset(1.42, 0.20),
    },
  );

  static const ringPress2d = GripMotionSpec2d(
    id: 'ring_press',
    label: 'Ring press',
    jointsStart: {
      'elbowL': Offset(0.22, 0.30),
      'elbowR': Offset(0.78, 0.30),
      'wristL': Offset(0.12, 0.32),
      'wristR': Offset(0.88, 0.32),
    },
    jointsEnd: {
      'elbowL': Offset(0.22, 0.30),
      'elbowR': Offset(0.78, 0.30),
      'wristL': Offset(0.47, 0.32),
      'wristR': Offset(0.53, 0.32),
    },
  );

  static const overheadRingPress2d = GripMotionSpec2d(
    id: 'overhead_ring_press',
    label: 'Overhead ring press',
    jointsStart: {
      'elbowL': Offset(0.30, 0.10),
      'elbowR': Offset(0.70, 0.10),
      'wristL': Offset(0.18, 0.04),
      'wristR': Offset(0.82, 0.04),
    },
    jointsEnd: {
      'elbowL': Offset(0.30, 0.10),
      'elbowR': Offset(0.70, 0.10),
      'wristL': Offset(0.47, 0.06),
      'wristR': Offset(0.53, 0.06),
    },
  );

  static final Map<String, GripTargetMotion3d> _motions3d = {
    'Pull Aparts': GripTargetMotion3d(pullAparts3d),
    'Ring Press': GripTargetMotion3d(ringPress3d),
    'Overhead Ring Press': GripTargetMotion3d(overheadRingPress3d),
  };

  static final Map<String, GripTargetMotion2d> _motions2d = {
    'Pull Aparts': GripTargetMotion2d(pullAparts2d),
    'Ring Press': GripTargetMotion2d(ringPress2d),
    'Overhead Ring Press': GripTargetMotion2d(overheadRingPress2d),
  };

  static WireframeFigureMotion? motionFor(String exerciseName) {
    switch (WireframeRendererConfig.mode) {
      case WireframeRendererMode.projected3d:
        return _motions3d[exerciseName];
      case WireframeRendererMode.flat2d:
        return _motions2d[exerciseName];
    }
  }

  static Iterable<GripMotionSpec3d> get allSpecs3d => _motions3d.values.map((m) => m.spec);

  static GripTargetMotion3d? motion3dFor(String exerciseName) => _motions3d[exerciseName];
}

/// Back-compat aliases for tests and imports.
const pullAparts3dMotion = GripTargetMotion3d(WireframeMotionRegistry.pullAparts3d);
const ringPress3dMotion = GripTargetMotion3d(WireframeMotionRegistry.ringPress3d);
const overheadRingPress3dMotion = GripTargetMotion3d(WireframeMotionRegistry.overheadRingPress3d);

typedef PullAparts3dMotion = GripTargetMotion3d;
typedef RingPress3dMotion = GripTargetMotion3d;
typedef OverheadRingPress3dMotion = GripTargetMotion3d;

const pullApartsMotion = GripTargetMotion2d(WireframeMotionRegistry.pullAparts2d);
const ringPressMotion = GripTargetMotion2d(WireframeMotionRegistry.ringPress2d);
const overheadRingPressMotion = GripTargetMotion2d(WireframeMotionRegistry.overheadRingPress2d);

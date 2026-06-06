import 'dart:ui';

import 'package:dawg/ui/avatar/body_pose_builder_3d.dart';
import 'package:dawg/ui/avatar/poses/neutral_standing_3d.dart';
import 'package:dawg/ui/avatar/poses/neutral_standing_front.dart';
import 'package:dawg/ui/avatar/poses/skeleton_3d_bones.dart';
import 'package:dawg/ui/avatar/wireframe_figure.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:dawg/ui/avatar/wireframe_pose_3d.dart';

/// Declarative grip targets for a rep — only these four points move.
class GripMotionSpec3d {
  const GripMotionSpec3d({
    required this.id,
    required this.label,
    required this.leftGripStart,
    required this.leftGripEnd,
    required this.rightGripStart,
    required this.rightGripEnd,
    this.leftElbow,
    this.rightElbow,
  });

  final String id;
  final String label;
  final WireframeVec3 leftGripStart;
  final WireframeVec3 leftGripEnd;
  final WireframeVec3 rightGripStart;
  final WireframeVec3 rightGripEnd;

  /// Fixed elbow for press-style motions; null = elbow on shoulder–grip line.
  final WireframeVec3? leftElbow;
  final WireframeVec3? rightElbow;
}

/// Front-view wrist/elbow overrides layered on [neutralStandingFront].
class GripMotionSpec2d {
  final String id;
  final String label;

  /// Keys: `wristL`, `wristR`, `elbowL`, `elbowR` (and optionally others).
  final Map<String, Offset> jointsStart;
  final Map<String, Offset> jointsEnd;
  final List<WireframeBone> extraBones;

  const GripMotionSpec2d({
    required this.id,
    required this.label,
    required this.jointsStart,
    required this.jointsEnd,
    this.extraBones = const [],
  });
}

/// 3D motion built from a [GripMotionSpec3d] — one implementation for all exercises.
class GripTargetMotion3d implements WireframeFigureMotion {
  const GripTargetMotion3d(this.spec);

  final GripMotionSpec3d spec;

  @override
  WireframeFigurePose get start => ProjectedWireframeFigurePose(buildPose(spec, 0));

  @override
  WireframeFigurePose poseAt(double repProgress) {
    return ProjectedWireframeFigurePose(
      buildPose(spec, wireframeRepPhase(repProgress)),
    );
  }

  static WireframePose3d buildPose(GripMotionSpec3d spec, double phase) {
    final joints = BodyPoseBuilder3d.copyJoints(neutralStanding3d.joints);

    final leftGrip = spec.leftGripStart.lerp(spec.leftGripEnd, phase);
    final rightGrip = spec.rightGripStart.lerp(spec.rightGripEnd, phase);

    BodyPoseBuilder3d.setFrontArm(
      joints,
      side: 'L',
      grip: leftGrip,
      elbow: spec.leftElbow,
    );
    BodyPoseBuilder3d.setFrontArm(
      joints,
      side: 'R',
      grip: rightGrip,
      elbow: spec.rightElbow,
    );

    return WireframePose3d(
      id: spec.id,
      label: spec.label,
      joints: joints,
      bones: skeleton3dBones,
    );
  }
}

/// 2D motion from wrist/elbow overrides on the neutral front pose.
class GripTargetMotion2d implements WireframeFigureMotion {
  const GripTargetMotion2d(this.spec);

  final GripMotionSpec2d spec;

  WireframePose get _startPose => _buildPose(spec.jointsStart);
  WireframePose get _endPose => _buildPose(spec.jointsEnd);

  @override
  WireframeFigurePose get start => FlatWireframeFigurePose(_startPose);

  @override
  WireframeFigurePose poseAt(double repProgress) {
    return FlatWireframeFigurePose(
      _startPose.lerp(_endPose, wireframeRepPhase(repProgress)),
    );
  }

  WireframePose _buildPose(Map<String, Offset> overrides) {
    final joints = Map<String, Offset>.from(neutralStandingFront.joints);
    joints.addAll(overrides);
    return WireframePose(
      id: spec.id,
      label: spec.label,
      joints: joints,
      bones: [...neutralStandingFront.bones, ...spec.extraBones],
      headJoint: neutralStandingFront.headJoint,
    );
  }
}

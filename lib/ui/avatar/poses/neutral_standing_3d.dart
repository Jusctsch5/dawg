import 'package:dawg/ui/avatar/body_pose_builder_3d.dart';
import 'package:dawg/ui/avatar/poses/skeleton_3d_bones.dart';
import 'package:dawg/ui/avatar/wireframe_pose_3d.dart';

/// Static torso + legs; arms built from grip targets at sides.
final WireframePose3d neutralStanding3d = _buildNeutralStanding();

WireframePose3d _buildNeutralStanding() {
  final joints = <String, WireframeVec3>{
    'head': WireframeVec3(0, 0.94, 0.02),
    'neck': WireframeVec3(0, 0.86, 0),
    'chest': WireframeVec3(0, 0.72, BodyPoseBuilder3d.torsoHalfDepth),
    'chestBack': WireframeVec3(0, 0.72, -BodyPoseBuilder3d.torsoHalfDepth),
    'pelvis': WireframeVec3(0, 0.48, BodyPoseBuilder3d.torsoHalfDepth),
    'pelvisBack': WireframeVec3(0, 0.48, -BodyPoseBuilder3d.torsoHalfDepth),
    'shoulderFL': WireframeVec3(-0.18, 0.80, BodyPoseBuilder3d.torsoHalfDepth),
    'shoulderFR': WireframeVec3(0.18, 0.80, BodyPoseBuilder3d.torsoHalfDepth),
    'shoulderBL': WireframeVec3(-0.18, 0.80, -BodyPoseBuilder3d.torsoHalfDepth),
    'shoulderBR': WireframeVec3(0.18, 0.80, -BodyPoseBuilder3d.torsoHalfDepth),
    'ribUpperFL': WireframeVec3(-0.14, 0.76, BodyPoseBuilder3d.torsoHalfDepth),
    'ribUpperFR': WireframeVec3(0.14, 0.76, BodyPoseBuilder3d.torsoHalfDepth),
    'ribUpperBL': WireframeVec3(-0.14, 0.76, -BodyPoseBuilder3d.torsoHalfDepth),
    'ribUpperBR': WireframeVec3(0.14, 0.76, -BodyPoseBuilder3d.torsoHalfDepth),
    'ribLowerFL': WireframeVec3(-0.12, 0.58, BodyPoseBuilder3d.torsoHalfDepth),
    'ribLowerFR': WireframeVec3(0.12, 0.58, BodyPoseBuilder3d.torsoHalfDepth),
    'ribLowerBL': WireframeVec3(-0.12, 0.58, -BodyPoseBuilder3d.torsoHalfDepth),
    'ribLowerBR': WireframeVec3(0.12, 0.58, -BodyPoseBuilder3d.torsoHalfDepth),
    'hipFL': WireframeVec3(-0.11, 0.48, BodyPoseBuilder3d.torsoHalfDepth),
    'hipFR': WireframeVec3(0.11, 0.48, BodyPoseBuilder3d.torsoHalfDepth),
    'hipBL': WireframeVec3(-0.11, 0.48, -BodyPoseBuilder3d.torsoHalfDepth),
    'hipBR': WireframeVec3(0.11, 0.48, -BodyPoseBuilder3d.torsoHalfDepth),
  };

  BodyPoseBuilder3d.setFrontArm(
    joints,
    side: 'L',
    grip: WireframeVec3(-0.19, 0.38, 0.14),
  );
  BodyPoseBuilder3d.setFrontArm(
    joints,
    side: 'R',
    grip: WireframeVec3(0.19, 0.38, 0.14),
  );
  BodyPoseBuilder3d.setLeg(
    joints,
    side: 'L',
    knee: WireframeVec3(-0.11, 0.28, 0.10),
    ankle: WireframeVec3(-0.11, 0.05, 0.08),
  );
  BodyPoseBuilder3d.setLeg(
    joints,
    side: 'R',
    knee: WireframeVec3(0.11, 0.28, 0.10),
    ankle: WireframeVec3(0.11, 0.05, 0.08),
  );

  return WireframePose3d(
    id: 'neutral_standing_3d',
    label: 'Neutral standing (3D)',
    joints: joints,
    bones: skeleton3dBones,
  );
}

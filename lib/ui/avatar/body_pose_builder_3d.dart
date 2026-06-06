import 'package:dawg/ui/avatar/wireframe_pose_3d.dart';

/// Builds dense limb chains and mirrors the front layer onto the back.
///
/// Joint suffix convention: `{part}FL` = front-left, `{part}BL` = back-left, etc.
class BodyPoseBuilder3d {
  /// Half-thickness of torso shell (+Z front, −Z back).
  static const torsoHalfDepth = 0.05;
  static const torsoDepth = torsoHalfDepth * 2;

  static WireframeVec3 mid(WireframeVec3 a, WireframeVec3 b) {
    return WireframeVec3(
      (a.x + b.x) / 2,
      (a.y + b.y) / 2,
      (a.z + b.z) / 2,
    );
  }

  static WireframeVec3 onSegment(WireframeVec3 from, WireframeVec3 to, double t) {
    return WireframeVec3(
      from.x + (to.x - from.x) * t,
      from.y + (to.y - from.y) * t,
      from.z + (to.z - from.z) * t,
    );
  }

  /// Constant shell offset from front shoulder to back shoulder.
  static WireframeVec3 shellOffset(WireframeVec3 shoulderF, WireframeVec3 shoulderB) {
    return WireframeVec3(
      shoulderB.x - shoulderF.x,
      shoulderB.y - shoulderF.y,
      shoulderB.z - shoulderF.z,
    );
  }

  static WireframeVec3 toBackShell(
    WireframeVec3 frontJoint,
    WireframeVec3 shoulderF,
    WireframeVec3 shoulderB,
  ) {
    final offset = shellOffset(shoulderF, shoulderB);
    return WireframeVec3(
      frontJoint.x + offset.x,
      frontJoint.y + offset.y,
      frontJoint.z + offset.z,
    );
  }

  /// Straight arm through [grip]; back shell is a parallel offset of the front chain.
  ///
  /// When [elbow] is set (e.g. ring press), the forearm pivots at a fixed elbow while
  /// only the grip moves — the ring compresses at the hands, not the whole arm.
  static void setFrontArm(
    Map<String, WireframeVec3> joints, {
    required String side,
    required WireframeVec3 grip,
    WireframeVec3? elbow,
  }) {
    final shoulderF = joints['shoulderF$side'];
    final shoulderB = joints['shoulderB$side'];
    if (shoulderF == null) {
      throw StateError('Missing joint shoulderF$side');
    }
    if (shoulderB == null) {
      throw StateError('Missing joint shoulderB$side');
    }

    final elbowF = elbow ?? onSegment(shoulderF, grip, 0.50);
    joints['armUpperF$side'] = mid(shoulderF, elbowF);
    joints['elbowF$side'] = elbowF;
    joints['armForeF$side'] = mid(elbowF, grip);
    joints['wristF$side'] = grip;
    joints['gripF$side'] = grip;

    for (final part in ['armUpper', 'elbow', 'armFore', 'wrist', 'grip']) {
      final front = joints['${part}F$side']!;
      joints['${part}B$side'] = toBackShell(front, shoulderF, shoulderB);
    }
  }

  static void setLeg(
    Map<String, WireframeVec3> joints, {
    required String side,
    required WireframeVec3 knee,
    required WireframeVec3 ankle,
  }) {
    final hip = joints['hipF$side'];
    if (hip == null) {
      throw StateError('Missing joint hipF$side');
    }

    final thighMid = mid(hip, knee);
    final shinMid = mid(knee, ankle);

    joints['thighMidF$side'] = thighMid;
    joints['kneeF$side'] = knee;
    joints['shinMidF$side'] = shinMid;
    joints['ankleF$side'] = ankle;

    final backZ = hip.z - torsoDepth;
    joints['thighMidB$side'] = WireframeVec3(thighMid.x, thighMid.y, backZ);
    joints['kneeB$side'] = WireframeVec3(knee.x, knee.y, backZ);
    joints['shinMidB$side'] = WireframeVec3(shinMid.x, shinMid.y, backZ);
    joints['ankleB$side'] = WireframeVec3(ankle.x, ankle.y, backZ);
  }

  static Map<String, WireframeVec3> copyJoints(Map<String, WireframeVec3> source) {
    return Map<String, WireframeVec3>.from(source);
  }
}

import 'dart:math' as math;

import 'package:dawg/ui/avatar/wireframe_pose.dart';

/// A joint position in body space (metres-ish proportions, Y up, +Z toward viewer).
class WireframeVec3 {
  const WireframeVec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  WireframeVec3 lerp(WireframeVec3 other, double t) {
    return WireframeVec3(
      x + (other.x - x) * t,
      y + (other.y - y) * t,
      z + (other.z - z) * t,
    );
  }

  WireframeVec3 rotateY(double radians) {
    final cosY = math.cos(radians);
    final sinY = math.sin(radians);
    return WireframeVec3(
      x * cosY + z * sinY,
      y,
      -x * sinY + z * cosY,
    );
  }

  WireframeVec3 rotateX(double radians) {
    final cosX = math.cos(radians);
    final sinX = math.sin(radians);
    return WireframeVec3(
      x,
      y * cosX - z * sinX,
      y * sinX + z * cosX,
    );
  }
}

/// Skeleton pose with 3D joint positions and shared bone list.
class WireframePose3d {
  const WireframePose3d({
    required this.id,
    required this.label,
    required this.joints,
    required this.bones,
    this.headJoint = 'head',
  });

  final String id;
  final String label;
  final Map<String, WireframeVec3> joints;
  final List<WireframeBone> bones;
  final String headJoint;

  WireframePose3d lerp(WireframePose3d other, double t) {
    final blended = <String, WireframeVec3>{};
    for (final key in joints.keys) {
      final a = joints[key];
      final b = other.joints[key];
      if (a == null || b == null) continue;
      blended[key] = a.lerp(b, t);
    }
    return WireframePose3d(
      id: id,
      label: label,
      joints: blended,
      bones: bones,
      headJoint: headJoint,
    );
  }
}

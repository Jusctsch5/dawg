import 'dart:ui';

/// A wireframe figure defined by normalized joint positions and bone connections.
///
/// Joint coordinates use normalized space: x and y range from 0 to 1, with
/// (0, 0) at the top-left of the figure bounds and (1, 1) at the bottom-right.
class WireframePose {
  const WireframePose({
    required this.id,
    required this.label,
    required this.joints,
    required this.bones,
    this.headJoint = 'head',
  });

  final String id;
  final String label;
  final Map<String, Offset> joints;
  final List<WireframeBone> bones;
  final String headJoint;
}

extension WireframePoseLerp on WireframePose {
  /// Interpolates joint positions toward [other]. Requires matching joint keys and bones.
  WireframePose lerp(WireframePose other, double t) {
    final blended = <String, Offset>{};
    for (final key in joints.keys) {
      final a = joints[key];
      final b = other.joints[key];
      if (a == null || b == null) continue;
      blended[key] = Offset.lerp(a, b, t)!;
    }
    return WireframePose(
      id: id,
      label: label,
      joints: blended,
      bones: bones,
      headJoint: headJoint,
    );
  }
}

/// Maps progress 0–1 through an out-and-back rep: start → end → start.
double wireframeRepPhase(double t) {
  final clamped = t.clamp(0.0, 1.0);
  if (clamped <= 0.5) {
    return clamped * 2;
  }
  return (1 - clamped) * 2;
}

class WireframeBone {
  const WireframeBone(this.from, this.to);

  final String from;
  final String to;
}

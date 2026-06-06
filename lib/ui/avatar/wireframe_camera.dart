import 'dart:math' as math;
import 'dart:ui';

import 'package:dawg/ui/avatar/poses/neutral_standing_3d.dart';
import 'package:dawg/ui/avatar/wireframe_pose_3d.dart';

WireframeVec3 orientBodyPoint(WireframeVec3 point, {double yaw = 0.55, double pitch = 0.12}) {
  return point.rotateY(yaw).rotateX(pitch);
}

/// Fixed 3/4 camera — projects body-space joints into a stable [0, 1]² frame.
class WireframeCamera {
  WireframeCamera({
    this.yaw = 0.55,
    this.pitch = 0.12,
    WireframeProjectionFrame? frame,
  }) : frame = frame ?? WireframeProjectionFrame.standard;

  final double yaw;
  final double pitch;
  final WireframeProjectionFrame frame;

  static final WireframeCamera workout = WireframeCamera();

  WireframeVec3 orient(WireframeVec3 point) {
    return orientBodyPoint(point, yaw: yaw, pitch: pitch);
  }

  Offset projectNormalized(WireframeVec3 point) {
    final oriented = orient(point);
    return frame.map(oriented.x, 1 - oriented.y);
  }

  double depthKey(WireframeVec3 point) => orient(point).z;
}

/// One scale/offset for every pose — no zooming during animation.
class WireframeProjectionFrame {
  const WireframeProjectionFrame({
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  final double scale;
  final double offsetX;
  final double offsetY;

  static final WireframeProjectionFrame standard = _buildStandard();

  static WireframeProjectionFrame _buildStandard() {
    const yaw = 0.55;
    const pitch = 0.12;

    // Fit to the standing body — not pull-apart extremes — so arm reach
    // does not shrink the whole figure when motion range increases.
    final samples = neutralStanding3d.joints.values;

    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final point in samples) {
      final oriented = orientBodyPoint(point, yaw: yaw, pitch: pitch);
      minX = math.min(minX, oriented.x);
      maxX = math.max(maxX, oriented.x);
      minY = math.min(minY, oriented.y);
      maxY = math.max(maxY, oriented.y);
    }

    const padding = 0.08;
    final spanX = math.max(maxX - minX, 0.001);
    final spanY = math.max(maxY - minY, 0.001);
    final scale = (1 - padding * 2) / math.max(spanX, spanY);
    final offsetX = padding - minX * scale + ((1 - padding * 2) - spanX * scale) / 2;
    final offsetY = padding - minY * scale + ((1 - padding * 2) - spanY * scale) / 2;

    return WireframeProjectionFrame(
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }

  Offset map(double x, double y) {
    return Offset(x * scale + offsetX, y * scale + offsetY);
  }
}

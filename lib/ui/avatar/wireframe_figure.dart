import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:dawg/ui/avatar/wireframe_pose_3d.dart';

/// Which wireframe backend to render.
enum WireframeRendererMode {
  flat2d,
  projected3d,
}

/// Global default — switch to [WireframeRendererMode.flat2d] to use the legacy 2D rig.
class WireframeRendererConfig {
  static WireframeRendererMode mode = WireframeRendererMode.projected3d;
}

/// Shared pose surface for 2D and projected-3D backends.
abstract class WireframeFigurePose {
  List<WireframeBone> get bones;
  String get headJoint;
}

/// Shared exercise motion surface for both backends.
abstract class WireframeFigureMotion {
  WireframeFigurePose get start;
  WireframeFigurePose poseAt(double repProgress);
}

class FlatWireframeFigurePose implements WireframeFigurePose {
  const FlatWireframeFigurePose(this.pose);

  final WireframePose pose;

  @override
  List<WireframeBone> get bones => pose.bones;

  @override
  String get headJoint => pose.headJoint;
}

class ProjectedWireframeFigurePose implements WireframeFigurePose {
  const ProjectedWireframeFigurePose(this.pose);

  final WireframePose3d pose;

  @override
  List<WireframeBone> get bones => pose.bones;

  @override
  String get headJoint => pose.headJoint;
}

class FlatWireframeFigureMotion implements WireframeFigureMotion {
  const FlatWireframeFigureMotion({
    required WireframePose start,
    required this.end,
  }) : _start = start;

  final WireframePose _start;
  final WireframePose end;

  WireframePose get startPose2d => _start;

  @override
  WireframeFigurePose get start => FlatWireframeFigurePose(_start);

  @override
  WireframeFigurePose poseAt(double repProgress) {
    return FlatWireframeFigurePose(_start.lerp(end, wireframeRepPhase(repProgress)));
  }
}

class ProjectedWireframeFigureMotion implements WireframeFigureMotion {
  const ProjectedWireframeFigureMotion({
    required WireframePose3d start,
    required this.end,
  }) : _start = start;

  final WireframePose3d _start;
  final WireframePose3d end;

  WireframePose3d get startPose3d => _start;

  @override
  WireframeFigurePose get start => ProjectedWireframeFigurePose(_start);

  @override
  WireframeFigurePose poseAt(double repProgress) {
    return ProjectedWireframeFigurePose(_start.lerp(end, wireframeRepPhase(repProgress)));
  }
}

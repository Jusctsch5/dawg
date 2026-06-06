import 'package:dawg/ui/avatar/exercise_pose_catalog.dart';
import 'package:dawg/ui/avatar/wireframe_figure.dart';
import 'package:dawg/ui/avatar/wireframe_painter_factory.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:flutter/material.dart';

export 'package:dawg/ui/avatar/poses/neutral_standing_front.dart';
export 'package:dawg/ui/avatar/poses/neutral_standing_3d.dart';
export 'package:dawg/ui/avatar/wireframe_figure.dart';
export 'package:dawg/ui/avatar/wireframe_pose.dart';
export 'package:dawg/ui/avatar/wireframe_pose_3d.dart';

/// Wireframe figure for exercise demos.
class WireframeAvatar extends StatelessWidget {
  const WireframeAvatar({
    super.key,
    this.pose,
    this.color,
    this.strokeWidth = 2.5,
  });

  /// When null, uses [ExercisePoseCatalog.defaultIdlePose] for the active renderer.
  final WireframeFigurePose? pose;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final figureColor = color ?? Theme.of(context).colorScheme.primary;
    final resolvedPose = pose ?? ExercisePoseCatalog.defaultIdlePose;

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: WireframePainterFactory.create(
            pose: resolvedPose,
            color: figureColor,
            strokeWidth: strokeWidth,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

/// Legacy helper — wraps a flat [WireframePose] for [WireframeAvatar].
class FlatWireframeAvatar extends StatelessWidget {
  const FlatWireframeAvatar({
    super.key,
    required this.pose,
    this.color,
    this.strokeWidth = 2.5,
  });

  final WireframePose pose;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return WireframeAvatar(
      pose: FlatWireframeFigurePose(pose),
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

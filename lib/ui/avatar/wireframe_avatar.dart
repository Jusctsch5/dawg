import 'package:dawg/ui/avatar/poses/neutral_standing_front.dart';
import 'package:dawg/ui/avatar/wireframe_avatar_painter.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:flutter/material.dart';

export 'package:dawg/ui/avatar/poses/neutral_standing_front.dart';
export 'package:dawg/ui/avatar/wireframe_pose.dart';

/// Wireframe figure for exercise demos. Defaults to [neutralStandingFront].
class WireframeAvatar extends StatelessWidget {
  const WireframeAvatar({
    super.key,
    this.pose = neutralStandingFront,
    this.color,
    this.strokeWidth = 2.5,
  });

  final WireframePose pose;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final figureColor = color ?? Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: WireframeAvatarPainter(
            pose: pose,
            color: figureColor,
            strokeWidth: strokeWidth,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

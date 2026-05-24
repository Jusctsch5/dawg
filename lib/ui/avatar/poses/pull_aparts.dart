import 'dart:ui';

import 'package:dawg/ui/avatar/poses/neutral_standing_front.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';

/// Arms extended in front at shoulder height, band held shoulder-width apart.
final pullApartsStart = WireframePose(
  id: 'pull_aparts_start',
  label: 'Pull aparts — start',
  joints: {
    'head': Offset(0.50, 0.08),
    'neck': Offset(0.50, 0.14),
    'shoulderL': Offset(0.34, 0.20),
    'shoulderR': Offset(0.66, 0.20),
    'elbowL': Offset(0.40, 0.24),
    'elbowR': Offset(0.60, 0.24),
    'wristL': Offset(0.46, 0.30),
    'wristR': Offset(0.54, 0.30),
    'hipL': Offset(0.42, 0.50),
    'hipR': Offset(0.58, 0.50),
    'kneeL': Offset(0.42, 0.70),
    'kneeR': Offset(0.58, 0.70),
    'ankleL': Offset(0.42, 0.90),
    'ankleR': Offset(0.58, 0.90),
  },
  bones: neutralStandingFront.bones,
);

/// Arms pulled apart to a T at shoulder level.
final pullApartsEnd = WireframePose(
  id: 'pull_aparts_end',
  label: 'Pull aparts — T shape',
  joints: {
    'head': Offset(0.50, 0.08),
    'neck': Offset(0.50, 0.14),
    'shoulderL': Offset(0.34, 0.20),
    'shoulderR': Offset(0.66, 0.20),
    'elbowL': Offset(0.24, 0.22),
    'elbowR': Offset(0.76, 0.22),
    'wristL': Offset(0.10, 0.22),
    'wristR': Offset(0.90, 0.22),
    'hipL': Offset(0.42, 0.50),
    'hipR': Offset(0.58, 0.50),
    'kneeL': Offset(0.42, 0.70),
    'kneeR': Offset(0.58, 0.70),
    'ankleL': Offset(0.42, 0.90),
    'ankleR': Offset(0.58, 0.90),
  },
  bones: neutralStandingFront.bones,
);

class WireframeExerciseMotion {
  const WireframeExerciseMotion({
    required this.start,
    required this.end,
  });

  final WireframePose start;
  final WireframePose end;

  WireframePose poseAt(double repProgress) {
    return start.lerp(end, wireframeRepPhase(repProgress));
  }
}

final pullApartsMotion = WireframeExerciseMotion(
  start: pullApartsStart,
  end: pullApartsEnd,
);

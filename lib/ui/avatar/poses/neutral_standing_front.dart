import 'dart:ui';

import 'package:dawg/ui/avatar/wireframe_pose.dart';

/// Front-facing neutral standing pose — arms at sides, feet hip-width apart.
const WireframePose neutralStandingFront = WireframePose(
  id: 'neutral_standing_front',
  label: 'Neutral standing',
  joints: {
    'head': Offset(0.50, 0.08),
    'neck': Offset(0.50, 0.14),
    'shoulderL': Offset(0.34, 0.20),
    'shoulderR': Offset(0.66, 0.20),
    'elbowL': Offset(0.29, 0.36),
    'elbowR': Offset(0.71, 0.36),
    'wristL': Offset(0.31, 0.54),
    'wristR': Offset(0.69, 0.54),
    'hipL': Offset(0.42, 0.50),
    'hipR': Offset(0.58, 0.50),
    'kneeL': Offset(0.42, 0.70),
    'kneeR': Offset(0.58, 0.70),
    'ankleL': Offset(0.42, 0.90),
    'ankleR': Offset(0.58, 0.90),
  },
  bones: [
    WireframeBone('neck', 'shoulderL'),
    WireframeBone('neck', 'shoulderR'),
    WireframeBone('shoulderL', 'shoulderR'),
    WireframeBone('shoulderL', 'hipL'),
    WireframeBone('shoulderR', 'hipR'),
    WireframeBone('hipL', 'hipR'),
    WireframeBone('shoulderL', 'elbowL'),
    WireframeBone('elbowL', 'wristL'),
    WireframeBone('shoulderR', 'elbowR'),
    WireframeBone('elbowR', 'wristR'),
    WireframeBone('hipL', 'kneeL'),
    WireframeBone('kneeL', 'ankleL'),
    WireframeBone('hipR', 'kneeR'),
    WireframeBone('kneeR', 'ankleR'),
  ],
);

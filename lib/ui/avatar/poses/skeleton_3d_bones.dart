import 'package:dawg/ui/avatar/wireframe_pose.dart';

/// Dense volumetric wireframe — subdivided limbs, rib cage, band grip line.
const List<WireframeBone> skeleton3dBones = [
  // Spine
  WireframeBone('head', 'neck'),
  WireframeBone('neck', 'chest'),
  WireframeBone('chest', 'pelvis'),

  // Front torso
  WireframeBone('chest', 'shoulderFL'),
  WireframeBone('chest', 'shoulderFR'),
  WireframeBone('shoulderFL', 'shoulderFR'),
  WireframeBone('shoulderFL', 'hipFL'),
  WireframeBone('shoulderFR', 'hipFR'),
  WireframeBone('hipFL', 'hipFR'),
  WireframeBone('pelvis', 'hipFL'),
  WireframeBone('pelvis', 'hipFR'),
  WireframeBone('ribUpperFL', 'ribUpperFR'),
  WireframeBone('ribLowerFL', 'ribLowerFR'),

  // Back torso
  WireframeBone('chest', 'shoulderBL'),
  WireframeBone('chest', 'shoulderBR'),
  WireframeBone('shoulderBL', 'shoulderBR'),
  WireframeBone('shoulderBL', 'hipBL'),
  WireframeBone('shoulderBR', 'hipBR'),
  WireframeBone('hipBL', 'hipBR'),
  WireframeBone('pelvis', 'hipBL'),
  WireframeBone('pelvis', 'hipBR'),
  WireframeBone('ribUpperBL', 'ribUpperBR'),
  WireframeBone('ribLowerBL', 'ribLowerBR'),

  // Torso depth posts + ribs depth
  WireframeBone('shoulderFL', 'shoulderBL'),
  WireframeBone('shoulderFR', 'shoulderBR'),
  WireframeBone('hipFL', 'hipBL'),
  WireframeBone('hipFR', 'hipBR'),
  WireframeBone('chest', 'chestBack'),
  WireframeBone('pelvis', 'pelvisBack'),
  WireframeBone('ribUpperFL', 'ribUpperBL'),
  WireframeBone('ribUpperFR', 'ribUpperBR'),
  WireframeBone('ribLowerFL', 'ribLowerBL'),
  WireframeBone('ribLowerFR', 'ribLowerBR'),

  // Front arms (subdivided)
  WireframeBone('shoulderFL', 'armUpperFL'),
  WireframeBone('armUpperFL', 'elbowFL'),
  WireframeBone('elbowFL', 'armForeFL'),
  WireframeBone('armForeFL', 'wristFL'),
  WireframeBone('wristFL', 'gripFL'),
  WireframeBone('shoulderFR', 'armUpperFR'),
  WireframeBone('armUpperFR', 'elbowFR'),
  WireframeBone('elbowFR', 'armForeFR'),
  WireframeBone('armForeFR', 'wristFR'),
  WireframeBone('wristFR', 'gripFR'),
  WireframeBone('gripFL', 'gripFR'),

  // Arm depth posts (front ↔ back)
  WireframeBone('elbowFL', 'elbowBL'),
  WireframeBone('elbowFR', 'elbowBR'),
  WireframeBone('wristFL', 'wristBL'),
  WireframeBone('wristFR', 'wristBR'),
  WireframeBone('shoulderBL', 'armUpperBL'),
  WireframeBone('armUpperBL', 'elbowBL'),
  WireframeBone('elbowBL', 'armForeBL'),
  WireframeBone('armForeBL', 'wristBL'),
  WireframeBone('wristBL', 'gripBL'),
  WireframeBone('shoulderBR', 'armUpperBR'),
  WireframeBone('armUpperBR', 'elbowBR'),
  WireframeBone('elbowBR', 'armForeBR'),
  WireframeBone('armForeBR', 'wristBR'),
  WireframeBone('wristBR', 'gripBR'),

  // Front legs
  WireframeBone('hipFL', 'thighMidFL'),
  WireframeBone('thighMidFL', 'kneeFL'),
  WireframeBone('kneeFL', 'shinMidFL'),
  WireframeBone('shinMidFL', 'ankleFL'),
  WireframeBone('hipFR', 'thighMidFR'),
  WireframeBone('thighMidFR', 'kneeFR'),
  WireframeBone('kneeFR', 'shinMidFR'),
  WireframeBone('shinMidFR', 'ankleFR'),

  // Back legs
  WireframeBone('hipBL', 'thighMidBL'),
  WireframeBone('thighMidBL', 'kneeBL'),
  WireframeBone('kneeBL', 'shinMidBL'),
  WireframeBone('shinMidBL', 'ankleBL'),
  WireframeBone('hipBR', 'thighMidBR'),
  WireframeBone('thighMidBR', 'kneeBR'),
  WireframeBone('kneeBR', 'shinMidBR'),
  WireframeBone('shinMidBR', 'ankleBR'),
];

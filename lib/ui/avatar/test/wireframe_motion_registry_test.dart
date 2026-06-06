import 'package:dawg/ui/avatar/poses/skeleton_3d_bones.dart';
import 'package:dawg/ui/avatar/wireframe_camera.dart';
import 'package:dawg/ui/avatar/wireframe_grip_motion.dart';
import 'package:dawg/ui/avatar/wireframe_motion_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dawg/ui/avatar/wireframe_pose.dart';

Set<String> _jointIdsForBones(List<WireframeBone> bones) {
  return {for (final bone in bones) bone.from, for (final bone in bones) bone.to};
}

void main() {
  group('WireframeMotionRegistry', () {
    test('every registered 3d spec builds a complete skeleton at key phases', () {
      for (final spec in WireframeMotionRegistry.allSpecs3d) {
        for (final phase in [0.0, 0.5, 1.0]) {
          final pose = GripTargetMotion3d.buildPose(spec, phase);
          for (final id in _jointIdsForBones(skeleton3dBones)) {
            expect(pose.joints.containsKey(id), isTrue, reason: '${spec.id} phase $phase missing $id');
          }
        }
      }
    });

    test('every registered 3d spec keeps back arms parallel on screen', () {
      final camera = WireframeCamera.workout;
      for (final spec in WireframeMotionRegistry.allSpecs3d) {
        for (final phase in [0.0, 0.5, 1.0]) {
          final pose = GripTargetMotion3d.buildPose(spec, phase);
          for (final side in ['L', 'R']) {
            final shoulderF = camera.projectNormalized(pose.joints['shoulderF$side']!);
            final shoulderB = camera.projectNormalized(pose.joints['shoulderB$side']!);
            final expectedDelta = shoulderB - shoulderF;

            for (final part in ['elbow', 'grip']) {
              final front = camera.projectNormalized(pose.joints['${part}F$side']!);
              final back = camera.projectNormalized(pose.joints['${part}B$side']!);
              final delta = back - front;
              expect(delta.dx, closeTo(expectedDelta.dx, 0.002), reason: '${spec.id} $side $part');
              expect(delta.dy, closeTo(expectedDelta.dy, 0.002), reason: '${spec.id} $side $part');
            }
          }
        }
      }
    });

    test('ring press spec compresses grips inward', () {
      final spec = WireframeMotionRegistry.ringPress3d;
      final start = GripTargetMotion3d.buildPose(spec, 0);
      final end = GripTargetMotion3d.buildPose(spec, 1);

      expect(
        end.joints['gripFR']!.x - end.joints['gripFL']!.x,
        lessThan(start.joints['gripFR']!.x - start.joints['gripFL']!.x),
      );
    });

    test('ring press keeps elbows fixed while grips move', () {
      final spec = WireframeMotionRegistry.ringPress3d;
      final start = GripTargetMotion3d.buildPose(spec, 0);
      final end = GripTargetMotion3d.buildPose(spec, 1);

      expect(start.joints['elbowFL'], spec.leftElbow);
      expect(start.joints['elbowFR'], spec.rightElbow);
      expect(end.joints['elbowFL'], spec.leftElbow);
      expect(end.joints['elbowFR'], spec.rightElbow);
      expect(end.joints['gripFL']!.x, greaterThan(start.joints['gripFL']!.x));
      expect(end.joints['gripFR']!.x, lessThan(start.joints['gripFR']!.x));
    });

    test('pull aparts spec spreads grips outward', () {
      final spec = WireframeMotionRegistry.pullAparts3d;
      final start = GripTargetMotion3d.buildPose(spec, 0);
      final end = GripTargetMotion3d.buildPose(spec, 1);

      expect(
        end.joints['gripFR']!.x - end.joints['gripFL']!.x,
        greaterThan(start.joints['gripFR']!.x - start.joints['gripFL']!.x),
      );
    });
  });
}

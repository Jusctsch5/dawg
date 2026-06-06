import 'dart:ui';

import 'package:dawg/ui/avatar/wireframe_camera.dart';
import 'package:dawg/ui/avatar/wireframe_grip_motion.dart';
import 'package:dawg/ui/avatar/wireframe_motion_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Projects every registered motion and prints front/back alignment.
///
/// Run from `dawg/`:
/// `flutter test lib/ui/avatar/test/wireframe_projection_debug_test.dart --reporter expanded`
void main() {
  const phases = [0.0, 0.5, 1.0];
  final camera = WireframeCamera.workout;

  for (final spec in WireframeMotionRegistry.allSpecs3d) {
    for (final phase in phases) {
      test('projection debug ${spec.id} phase=$phase', () {
        final pose = GripTargetMotion3d.buildPose(spec, phase);
        final projected = <String, Offset>{};
        for (final entry in pose.joints.entries) {
          projected[entry.key] = camera.projectNormalized(entry.value);
        }

        // ignore: avoid_print
        print('\n=== ${spec.label} phase $phase ===');
        for (final side in ['L', 'R']) {
          const pairs = [
            ['shoulderF', 'shoulderB'],
            ['elbowF', 'elbowB'],
            ['gripF', 'gripB'],
          ];
          for (final pair in pairs) {
            final f = projected['${pair[0]}$side']!;
            final b = projected['${pair[1]}$side']!;
            final delta = b - f;
            // ignore: avoid_print
            print(
              '$side ${pair[0]}/${pair[1]}: '
              'front=(${f.dx.toStringAsFixed(3)}, ${f.dy.toStringAsFixed(3)}) '
              'back=(${b.dx.toStringAsFixed(3)}, ${b.dy.toStringAsFixed(3)}) '
              'Δ=(${delta.dx.toStringAsFixed(3)}, ${delta.dy.toStringAsFixed(3)})',
            );
          }
        }
      });
    }
  }
}

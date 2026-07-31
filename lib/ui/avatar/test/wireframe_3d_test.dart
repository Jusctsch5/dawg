import 'package:dawg/common_defines.dart';
import 'package:dawg/ui/avatar/exercise_pose_catalog.dart';
import 'package:dawg/ui/avatar/exercise_wireframe_view.dart';
import 'package:dawg/ui/avatar/poses/neutral_standing_3d.dart';
import 'package:dawg/ui/avatar/poses/pull_aparts_3d.dart';
import 'package:dawg/ui/avatar/poses/ring_press_3d.dart';
import 'package:dawg/ui/avatar/poses/skeleton_3d_bones.dart';
import 'package:dawg/ui/avatar/wireframe_camera.dart';
import 'package:dawg/ui/avatar/wireframe_figure.dart';
import 'package:dawg/ui/avatar/wireframe_grip_motion.dart';
import 'package:dawg/ui/avatar/wireframe_motion_registry.dart';
import 'package:dawg/ui/avatar/wireframe_painter_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('neutralStanding3d', () {
    test('defines every joint referenced by skeleton3dBones', () {
      for (final id in {for (final b in skeleton3dBones) b.from, for (final b in skeleton3dBones) b.to}) {
        expect(neutralStanding3d.joints.containsKey(id), isTrue, reason: 'missing $id');
      }
    });
  });

  group('GripTargetMotion3d', () {
    test('pull aparts reaches forward then spreads', () {
      final start = GripTargetMotion3d.buildPose(WireframeMotionRegistry.pullAparts3d, 0);
      final end = GripTargetMotion3d.buildPose(WireframeMotionRegistry.pullAparts3d, 1);

      expect(start.joints['gripFL']!.z, greaterThan(end.joints['gripFL']!.z));
      expect(
        end.joints['gripFR']!.x - end.joints['gripFL']!.x,
        greaterThan(end.joints['gripFR']!.x - start.joints['gripFL']!.x),
      );
    });

    test('poseAt does not throw across rep cycle', () {
      final motion = WireframeMotionRegistry.motion3dFor('Pull Aparts')!;
      for (var t = 0.0; t <= 1.0; t += 0.1) {
        expect(motion.poseAt(t), isA<ProjectedWireframeFigurePose>());
      }
    });
  });

  group('WireframeCamera', () {
    test('projects neutral joints into normalized frame', () {
      final camera = WireframeCamera.workout;
      for (final joint in neutralStanding3d.joints.values) {
        final projected = camera.projectNormalized(joint);
        expect(projected.dx, inInclusiveRange(-0.05, 1.05));
        expect(projected.dy, inInclusiveRange(-0.05, 1.05));
      }
    });
  });

  group('WireframePainterFactory', () {
    test('creates 3d painter without throwing', () {
      final pose = ProjectedWireframeFigurePose(
        GripTargetMotion3d.buildPose(WireframeMotionRegistry.pullAparts3d, 0.5),
      );
      expect(
        () => WireframePainterFactory.create(pose: pose, color: Colors.blue),
        returnsNormally,
      );
    });
  });

  group('ExerciseWireframeView', () {
    testWidgets('renders Pull Aparts without exceptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: ExerciseWireframeView(exerciseName: 'Pull Aparts'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Ring Press with animated wireframe', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: ExerciseWireframeView(
                exerciseName: 'Ring Press',
                equipment: [Equipment.ring],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(tester.takeException(), isNull);
      expect(ExercisePoseCatalog.motionForExercise('Ring Press'), isA<GripTargetMotion3d>());
    });

    testWidgets('renders static pose when animateWireframes is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: ExerciseWireframeView(
                exerciseName: 'Ring Press',
                equipment: [Equipment.ring],
                animateWireframes: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Suspended Row with equipment wireframe', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: ExerciseWireframeView(
                exerciseName: 'Suspended Row',
                equipment: [Equipment.suspendedBand],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('ExercisePoseCatalog', () {
    test('returns registered 3d motions', () {
      expect(WireframeRendererConfig.mode, WireframeRendererMode.projected3d);
      expect(ExercisePoseCatalog.motionForExercise('Pull Aparts'), isA<PullAparts3dMotion>());
      expect(ExercisePoseCatalog.motionForExercise('Ring Press'), isA<RingPress3dMotion>());
    });
  });
}

import 'package:dawg/common_defines.dart';
import 'package:dawg/ui/avatar/poses/neutral_standing_3d.dart';
import 'package:dawg/ui/avatar/wireframe_grip_motion.dart';
import 'package:dawg/ui/avatar/wireframe_motion_registry.dart';
import 'package:dawg/ui/avatar/wireframe_equipment.dart';
import 'package:dawg/ui/avatar/wireframe_equipment_layout.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WireframeEquipmentLayout', () {
    test('adds suspended band anchors and straps for 3d neutral pose', () {
      final augmented = WireframeEquipmentLayout.augment3d(
        neutralStanding3d,
        [Equipment.suspendedBand],
      );

      expect(augmented.joints.containsKey('eqSuspAnchorFL'), isTrue);
      expect(augmented.joints.containsKey('eqSuspAnchorFR'), isTrue);
      expect(
        augmented.bones.any((b) => b.from == 'eqSuspAnchorFL' && b.to == 'gripFL'),
        isTrue,
      );
      expect(
        augmented.bones.any((b) => b.from == 'eqSuspAnchorFL' && b.to == 'eqSuspAnchorFR'),
        isTrue,
      );
    });

    test('adds ring loop between hands for 3d neutral pose', () {
      final augmented = WireframeEquipmentLayout.augment3d(
        neutralStanding3d,
        [Equipment.ring],
      );

      expect(augmented.joints.containsKey('eqRing0'), isTrue);
      expect(augmented.bones.where((b) => b.from.startsWith('eqRing')).length, greaterThan(4));
    });

    test('ring loop is horizontal and ties to grip points on the loop', () {
      final augmented = WireframeEquipmentLayout.augment3d(
        GripTargetMotion3d.buildPose(WireframeMotionRegistry.ringPress3d, 0.5),
        [Equipment.ring],
      );

      final centerY = augmented.joints['gripFL']!.y;
      for (var i = 0; i < 8; i++) {
        expect(augmented.joints['eqRing$i']!.y, closeTo(centerY, 0.001));
      }
      expect(augmented.joints['eqRing0'], augmented.joints['gripFR']);
      expect(augmented.joints['eqRing4'], augmented.joints['gripFL']);
    });

    test('adds dumbbell bars and plate joints for 3d neutral pose', () {
      final augmented = WireframeEquipmentLayout.augment3d(
        neutralStanding3d,
        [Equipment.freeWeight],
      );

      expect(augmented.joints.containsKey('eqWeightPlateOutFL'), isTrue);
      expect(augmented.joints.containsKey('eqWeightPlateOutFR'), isTrue);
      expect(
        augmented.bones.any((b) => b.from == 'eqWeightOutFL' && b.to == 'eqWeightInFL'),
        isTrue,
      );
    });

    test('pull aparts keeps resistance band bone when equipment listed', () {
      final augmented = WireframeEquipmentLayout.augment3d(
        GripTargetMotion3d.buildPose(WireframeMotionRegistry.pullAparts3d, 0.5),
        [Equipment.resistanceBand],
      );

      final band = const WireframeBone('gripFL', 'gripFR');
      expect(WireframeEquipment.equipmentForBone(band, [Equipment.resistanceBand]),
          Equipment.resistanceBand);
      expect(augmented.bones.any((b) => b.from == 'gripFL' && b.to == 'gripFR'), isTrue);
    });

    test('does not style band bone without resistanceBand equipment', () {
      const band = WireframeBone('gripFL', 'gripFR');
      expect(WireframeEquipment.equipmentForBone(band, [Equipment.ring]), isNull);
    });
  });

  group('WireframeEquipment colors', () {
    test('each equipment type has a distinct color', () {
      final colors = {
        WireframeEquipment.colorFor(Equipment.resistanceBand),
        WireframeEquipment.colorFor(Equipment.suspendedBand),
        WireframeEquipment.colorFor(Equipment.ring),
        WireframeEquipment.colorFor(Equipment.freeWeight),
      };
      expect(colors.length, 4);
    });
  });
}

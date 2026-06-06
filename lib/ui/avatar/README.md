# Wireframe avatars

Pseudo-3D exercise wireframes: volumetric stick cages projected to 2D with a fixed 3/4 camera.

## Add an exercise animation (maintainable path)

**Do not create a new motion class.** Add one entry to `wireframe_motion_registry.dart`:

```dart
static const myExercise3d = GripMotionSpec3d(
  id: 'my_exercise_3d',
  label: 'My exercise (3D)',
  leftGripStart: WireframeVec3(-0.32, 0.58, 0.34),   // rep start — left hand
  leftGripEnd: WireframeVec3(-0.08, 0.58, 0.34),     // rep end — left hand
  rightGripStart: WireframeVec3(0.32, 0.58, 0.34),   // rep start — right hand
  rightGripEnd: WireframeVec3(0.08, 0.58, 0.34),     // rep end — right hand
);

// In _motions3d:
'My Exercise': GripTargetMotion3d(myExercise3d),
```

That's it for 3D. `GripTargetMotion3d` rebuilds both arms from neutral via `BodyPoseBuilder3d.setFrontArm()`. Equipment comes from the exercise's `equipment` list in app config (not the registry).

Optional 2D legacy entry: add a `GripMotionSpec2d` with `wristL` / `wristR` / `elbowL` / `elbowR` overrides at start and end.

### Automatic tests

`flutter test lib/ui/avatar/test/wireframe_motion_registry_test.dart`

Every registered spec is checked for:

- Complete skeleton joints at phases 0, 0.5, 1.0
- Back arms parallel to front on screen (3/4 camera)

Add exercise-specific assertions there only when needed (e.g. compress vs spread).

### Simulate on screen

```bash
cd dawg
flutter test lib/ui/avatar/test/wireframe_projection_debug_test.dart --reporter expanded
```

Runs projection debug for **all** registry motions. Healthy output: identical `Δ` for shoulder, elbow, and grip on each side.

## Architecture

| Piece | Role |
|-------|------|
| `wireframe_motion_registry.dart` | **Single table** of exercise → grip targets |
| `wireframe_grip_motion.dart` | One 3D + one 2D motion implementation |
| `body_pose_builder_3d.dart` | Arm chains + back-shell offset |
| `wireframe_equipment_layout.dart` | Ring, bands, straps, dumbbells from equipment list |
| `wireframe_equipment.dart` | Equipment colors |
| `wireframe_camera.dart` | Fixed 3/4 projection |

## Body space

| Axis | Meaning |
|------|---------|
| Y | Up (feet ~0.05, head ~0.94) |
| +Z | Toward viewer |
| Front/back shell | ±`torsoHalfDepth` (0.05) |

Joint suffix: `FL`/`FR` front, `BL`/`BR` back — never `LF`/`RF`.

## Equipment wireframes

Injected by `WireframeEquipmentLayout` from the exercise `equipment` list:

| Equipment | Color | Shape |
|-----------|-------|-------|
| `resistanceBand` | Red | Line between hands |
| `suspendedBand` | Teal | Anchor bar + straps |
| `ring` | Amber | Horizontal loop; grips on opposite points; radius tracks compression |
| `freeWeight` | Steel | Dumbbell bar + plate circles |

## Reference files

| File | Role |
|------|------|
| `wireframe_motion_registry.dart` | Add new animations here |
| `wireframe_grip_motion.dart` | Grip-driven motion builder |
| `body_pose_builder_3d.dart` | `toBackShell`, `setFrontArm` |
| `test/wireframe_motion_registry_test.dart` | Registry regression tests |
| `test/wireframe_projection_debug_test.dart` | Screen projection dump |

Cursor agents: `.cursor/rules/pseudo-3d-wireframe.mdc`

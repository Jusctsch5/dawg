import 'package:dawg/common_defines.dart';
import 'package:dawg/ui/avatar/exercise_pose_catalog.dart';
import 'package:dawg/ui/avatar/wireframe_equipment_layout.dart';
import 'package:dawg/ui/avatar/wireframe_figure.dart';
import 'package:dawg/ui/avatar/wireframe_painter_factory.dart';
import 'package:dawg/workout/workout_playback_state.dart';
import 'package:flutter/material.dart';

/// Displays a wireframe figure for the active exercise, with motion when defined.
class ExerciseWireframeView extends StatefulWidget {
  const ExerciseWireframeView({
    super.key,
    this.exerciseName,
    this.equipment = const [],
    this.playbackState = const WorkoutPlaybackState(),
    this.color,
    this.strokeWidth = 2.5,
  });

  final String? exerciseName;
  final List<Equipment> equipment;
  final WorkoutPlaybackState playbackState;
  final Color? color;
  final double strokeWidth;

  @override
  State<ExerciseWireframeView> createState() => _ExerciseWireframeViewState();
}

class _ExerciseWireframeViewState extends State<ExerciseWireframeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final figureColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final motion = widget.exerciseName != null
        ? ExercisePoseCatalog.motionForExercise(widget.exerciseName!)
        : null;

    if (motion == null) {
      return _WireframePaint(
        pose: WireframeEquipmentLayout.augmentFigure(
          ExercisePoseCatalog.defaultIdlePose,
          widget.equipment,
        ),
        equipment: widget.equipment,
        color: figureColor,
        strokeWidth: widget.strokeWidth,
      );
    }

    final segment = widget.playbackState.segment;
    final animating = !widget.playbackState.isPlaying ||
        segment == WorkoutSegment.exerciseDescription ||
        segment == WorkoutSegment.activeSet;

    if (animating) {
      return AnimatedBuilder(
        animation: _loopController,
        builder: (context, _) {
          return _WireframePaint(
            pose: WireframeEquipmentLayout.augmentFigure(
              motion.poseAt(_loopController.value),
              widget.equipment,
            ),
            equipment: widget.equipment,
            color: figureColor,
            strokeWidth: widget.strokeWidth,
          );
        },
      );
    }

    return _WireframePaint(
      pose: WireframeEquipmentLayout.augmentFigure(motion.start, widget.equipment),
      equipment: widget.equipment,
      color: figureColor,
      strokeWidth: widget.strokeWidth,
    );
  }
}

class _WireframePaint extends StatelessWidget {
  const _WireframePaint({
    required this.pose,
    required this.equipment,
    required this.color,
    required this.strokeWidth,
  });

  final WireframeFigurePose pose;
  final List<Equipment> equipment;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: WireframePainterFactory.create(
            pose: pose,
            equipment: equipment,
            color: color,
            strokeWidth: strokeWidth,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

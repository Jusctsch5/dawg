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
    this.animateWireframes = true,
    this.color,
    this.strokeWidth = 2.5,
  });

  final String? exerciseName;
  final List<Equipment> equipment;
  final WorkoutPlaybackState playbackState;
  final bool animateWireframes;
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
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(ExerciseWireframeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playbackState.isPaused != widget.playbackState.isPaused ||
        oldWidget.playbackState.isPlaying != widget.playbackState.isPlaying ||
        oldWidget.playbackState.segment != widget.playbackState.segment ||
        oldWidget.animateWireframes != widget.animateWireframes) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  bool _shouldAnimate() {
    if (!widget.animateWireframes) return false;

    final segment = widget.playbackState.segment;
    return (!widget.playbackState.isPlaying ||
            segment == WorkoutSegment.exerciseDescription ||
            segment == WorkoutSegment.activeSet) &&
        !widget.playbackState.isPaused;
  }

  void _syncAnimation() {
    if (_shouldAnimate()) {
      if (!_loopController.isAnimating) {
        _loopController.repeat();
      }
    } else {
      _loopController.stop();
    }
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

    if (_shouldAnimate()) {
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

    final pose = widget.playbackState.isPaused && widget.animateWireframes
        ? motion.poseAt(_loopController.value)
        : motion.start;

    return _WireframePaint(
      pose: WireframeEquipmentLayout.augmentFigure(pose, widget.equipment),
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

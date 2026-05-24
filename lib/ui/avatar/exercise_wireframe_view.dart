import 'package:dawg/ui/avatar/exercise_pose_catalog.dart';
import 'package:dawg/ui/avatar/poses/neutral_standing_front.dart';
import 'package:dawg/ui/avatar/wireframe_avatar_painter.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';
import 'package:dawg/workout/workout_playback_state.dart';
import 'package:flutter/material.dart';

/// Displays a wireframe figure for the active exercise, with motion when defined.
class ExerciseWireframeView extends StatefulWidget {
  const ExerciseWireframeView({
    super.key,
    this.exerciseName,
    this.playbackState = const WorkoutPlaybackState(),
    this.color,
    this.strokeWidth = 2.5,
  });

  final String? exerciseName;
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
        pose: neutralStandingFront,
        color: figureColor,
        strokeWidth: widget.strokeWidth,
      );
    }

    if (widget.playbackState.isPlaying) {
      final pose = widget.playbackState.segment == WorkoutSegment.activeSet
          ? motion.poseAt(widget.playbackState.segmentProgress)
          : motion.start;
      return _WireframePaint(
        pose: pose,
        color: figureColor,
        strokeWidth: widget.strokeWidth,
      );
    }

    return AnimatedBuilder(
      animation: _loopController,
      builder: (context, _) {
        return _WireframePaint(
          pose: motion.poseAt(_loopController.value),
          color: figureColor,
          strokeWidth: widget.strokeWidth,
        );
      },
    );
  }
}

class _WireframePaint extends StatelessWidget {
  const _WireframePaint({
    required this.pose,
    required this.color,
    required this.strokeWidth,
  });

  final WireframePose pose;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: WireframeAvatarPainter(
            pose: pose,
            color: color,
            strokeWidth: strokeWidth,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

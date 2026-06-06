import 'package:dawg/ui/avatar/poses/neutral_standing_3d.dart';
import 'package:dawg/ui/avatar/poses/neutral_standing_front.dart';
import 'package:dawg/ui/avatar/wireframe_figure.dart';
import 'package:dawg/ui/avatar/wireframe_motion_registry.dart';

class ExercisePoseCatalog {
  static WireframeFigureMotion? motionForExercise(String exerciseName) {
    return WireframeMotionRegistry.motionFor(exerciseName);
  }

  static WireframeFigurePose idlePoseForExercise(String exerciseName) {
    return motionForExercise(exerciseName)?.start ?? defaultIdlePose;
  }

  static WireframeFigurePose get defaultIdlePose {
    switch (WireframeRendererConfig.mode) {
      case WireframeRendererMode.projected3d:
        return ProjectedWireframeFigurePose(neutralStanding3d);
      case WireframeRendererMode.flat2d:
        return const FlatWireframeFigurePose(neutralStandingFront);
    }
  }
}

import 'package:dawg/ui/avatar/poses/neutral_standing_front.dart';
import 'package:dawg/ui/avatar/poses/pull_aparts.dart';
import 'package:dawg/ui/avatar/wireframe_pose.dart';

class ExercisePoseCatalog {
  static WireframeExerciseMotion? motionForExercise(String exerciseName) {
    switch (exerciseName) {
      case 'Pull Aparts':
        return pullApartsMotion;
      default:
        return null;
    }
  }

  static WireframePose idlePoseForExercise(String exerciseName) {
    return motionForExercise(exerciseName)?.start ?? neutralStandingFront;
  }
}

import 'package:geolocator/geolocator.dart';

//might be useful one day
final class WorkoutPoint {
  final Position position;

  const WorkoutPoint(this.position);

  static double distanceBetween(WorkoutPoint a, WorkoutPoint b) {
    return Geolocator.distanceBetween(a.position.latitude, a.position.longitude,
            b.position.latitude, b.position.longitude) /
        1000;
  }

  static String paceBetween(WorkoutPoint a, WorkoutPoint b, Duration duration) {
    double distance = distanceBetween(a, b);
    double pace = duration.inSeconds / distance;
    if (pace.isNaN || pace.isInfinite) return "-";
    int minutes = pace ~/ 60;
    int seconds = (pace % 60).round();
    if (minutes > 20) return "-";
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}/km';
  }

  @override
  String toString() {
    return 'WorkoutPoint{position: ${position.toString()}';
  }
}

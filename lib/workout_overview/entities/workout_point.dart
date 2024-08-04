import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workout_repository/workout_repository.dart';

//might be useful one day
final class WorkoutPoint {
  final double latitude;
  final double longitude;
  final int orderPriority;

  const WorkoutPoint(
      {required this.latitude,
      required this.longitude,
      required this.orderPriority});

  static double distanceBetween(WorkoutPoint a, WorkoutPoint b) {
    return Geolocator.distanceBetween(
            a.latitude, a.longitude, b.latitude, b.longitude) /
        1000;
  }

  static String paceBetween(WorkoutPoint a, WorkoutPoint b, Duration duration) {
    double distance = distanceBetween(a, b);
    double pace = duration.inSeconds / distance;
    if (pace.isNaN || pace.isInfinite) return "-";
    int minutes = pace ~/ 60;
    int seconds = (pace % 60).floor();
    if (minutes >= 20) return "-";
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}/km';
  }

  static LatLng approximateMidpoint(WorkoutPoint a, WorkoutPoint b) {
    return LatLng(
      (a.latitude + b.latitude) / 2,
      (a.longitude + b.longitude) / 2,
    );
  }

  WorkoutPointData toData() {
    return WorkoutPointData(
      latitude: latitude,
      longitude: longitude,
      orderPriority: orderPriority,
    );
  }

  factory WorkoutPoint.fromPosition(Position position, int orderPriority) {
    return WorkoutPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      orderPriority: orderPriority,
    );
  }

  factory WorkoutPoint.fromData(WorkoutPointData data) {
    return WorkoutPoint(
      latitude: data.latitude,
      longitude: data.longitude,
      orderPriority: data.orderPriority,
    );
  }

  @override
  String toString() {
    return 'WorkoutPoint{latitude: $latitude, longitude: $longitude, orderPriority: $orderPriority}';
  }
}

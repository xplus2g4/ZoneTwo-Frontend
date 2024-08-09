import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zonetwo/workout_overview/entities/workout_point.dart';

class WorkoutDetailMap extends StatelessWidget {
  const WorkoutDetailMap(
      {required this.points, required this.workoutId, super.key});

  final List<WorkoutPoint> points;
  final String workoutId;

  @override
  Widget build(BuildContext context) {
    return points.isEmpty
        ? const Text("No location data for this workout")
        : GoogleMap(
            initialCameraPosition: CameraPosition(
                target:
                    WorkoutPoint.approximateMidpoint(points.first, points.last),
                zoom: 15 -
                    0.1 *
                    WorkoutPoint.distanceBetween(points.first, points.last)),
            markers: {
              Marker(
                markerId: MarkerId('$workoutId start'),
                position: LatLng(points.first.latitude, points.first.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
              Marker(
                  markerId: MarkerId('$workoutId end'),
                  position: LatLng(points.last.latitude, points.last.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed)),
            },
            polylines: {
              Polyline(
                polylineId: PolylineId(workoutId),
                points:
                    points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                geodesic: true,
                color: Colors.blue,
                jointType: JointType.round,
              ),
            },
          );
  }
}

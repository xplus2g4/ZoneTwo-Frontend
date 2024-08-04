import 'package:workout_repository/src/data_models/workout_point_data.dart';

class WorkoutData {
  final String id;
  final String datetime;
  final int duration; //in seconds
  final double distance;

  const WorkoutData({
    required this.id,
    required this.datetime,
    required this.duration,
    required this.distance,
  });

  WorkoutData.newData(
      {required this.datetime, required this.duration, required this.distance})
      : id = "";

  factory WorkoutData.fromRow(Map<String, Object?> row) {
    return WorkoutData(
        id: row['id'] as String,
        datetime: row['datetime'] as String,
        duration: row['duration'] as int,
        distance: row['distance'] as double);
  }

  WorkoutData update(
      {String? id, String? datetime, int? duration, double? distance}) {
    return WorkoutData(
      id: id ?? this.id,
      datetime: datetime ?? this.datetime,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
    );
  }

  Map<String, Object?> toRow() {
    return {
      'id': id,
      'datetime': datetime,
      'duration': duration,
      'distance': distance,
    };
  }

  @override
  String toString() {
    return 'Workout{id: $id, datetime: $datetime, duration: $duration, distance: $distance}';
  }
}

class WorkoutWithPointsData extends WorkoutData {
  WorkoutWithPointsData(
      {required super.id,
      required super.datetime,
      required super.duration,
      required super.distance,
      required this.points});

  final List<WorkoutPointData> points;
}


import 'package:intl/intl.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/workout_overview/entities/workout_point.dart';

class WorkoutEntity {
  final String id;
  final DateTime datetime;
  final Duration duration;
  final double distance;

  WorkoutEntity({
    required this.id,
    required this.datetime,
    required this.duration,
    required this.distance,
  });

  factory WorkoutEntity.fromData(WorkoutData data) {
    return WorkoutEntity(
      id: data.id,
      datetime: DateTime.parse(data.datetime),
      duration: Duration(seconds: data.duration),
      distance: data.distance,
    );
  }

  WorkoutData toData() {
    return WorkoutData(
      id: id,
      datetime: datetime.toIso8601String(),
      duration: duration.inSeconds,
      distance: distance,
    );
  }
}

class WorkoutWithPointsEntity extends WorkoutEntity {
  final List<WorkoutPoint> points;

  WorkoutWithPointsEntity({
    required super.id,
    required super.datetime,
    required super.duration,
    required super.distance,
    required this.points,
  });

  factory WorkoutWithPointsEntity.fromData(WorkoutWithPointsData data) {
    return WorkoutWithPointsEntity(
      id: data.id,
      datetime: DateTime.parse(data.datetime),
      duration: Duration(seconds: data.duration),
      distance: data.distance,
      points: data.points.map((e) => WorkoutPoint.fromData(e)).toList(),
    );
  }

  @override
  WorkoutWithPointsData toData() {
    return WorkoutWithPointsData(
      id: id,
      datetime: DateFormat('EEE MMM d yyyy').add_jm().format(datetime),
      duration: duration.inSeconds,
      distance: distance,
      points: points.map((e) => e.toData()).toList(),
    );
  }
}

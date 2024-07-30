import 'package:intl/intl.dart';
import 'package:workout_repository/workout_repository.dart';

class WorkoutEntity {
  final String id;
  final DateTime datetime;
  final Duration duration;
  final num distance;

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
      datetime: DateFormat('EEE MMM d yyyy').add_jm().format(datetime),
      duration: duration.inSeconds,
      distance: distance,
    );
  }
}

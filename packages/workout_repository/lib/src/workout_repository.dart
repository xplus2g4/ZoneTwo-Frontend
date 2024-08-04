import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/v4.dart';
import 'package:rxdart/subjects.dart';

import 'data_models/data_models.dart';

class WorkoutRepository {
  static const tableName = "workouts";
  static const joinTableName = "workout_points";
  WorkoutRepository(this._db);

  final Database _db;
  late final _workoutStreamController =
      BehaviorSubject<List<WorkoutData>>.seeded(
    const [],
  );

  late final _workoutWithPointsStreamController =
      BehaviorSubject<WorkoutWithPointsData>();

  Stream<List<WorkoutData>> getWorkoutStream() =>
      _workoutStreamController.asBroadcastStream();
      
  Stream<WorkoutWithPointsData> getWorkoutWithPointsStream() =>
      _workoutWithPointsStreamController.asBroadcastStream();

  Future<void> addWorkoutData(WorkoutWithPointsData workoutData) async {
    final newId = const UuidV4().generate();
    await _db.transaction((txn) async {
      await txn.rawInsert(
        "INSERT INTO $tableName(id, datetime, duration, distance) VALUES(?, ?, ?, ?)",
        [
          newId,
          workoutData.datetime,
          workoutData.duration,
          workoutData.distance,
          ]);

      if (workoutData.points.isNotEmpty) {
        await txn.rawInsert(
          "INSERT INTO $joinTableName(id, workout_id, order_priority, latitude, longitude) VALUES ${workoutData.points.map((point) => "('${const UuidV4().generate()}', '$newId', '${point.orderPriority}', '${point.latitude}', '${point.longitude}')").join(", ")}");
      }
    });
    final workout = [..._workoutStreamController.value];
    final newWorkout = workoutData.update(id: newId);
    workout.add(newWorkout);
    _workoutStreamController.add(workout);
  }

  Future<void> getAllWorkouts() async {
    final workout =
        (await _db.query(tableName)).map(WorkoutData.fromRow).toList();
    _workoutStreamController.add(workout);
  }

  Future<void> getWorkoutWithPoints(WorkoutData workout) async {
    final points = (await _db.rawQuery('''
      SELECT * FROM $joinTableName
      WHERE workout_id = ?
    ''', [workout.id])).map(WorkoutPointData.fromRow).toList();
    points.sort((a, b) => a.orderPriority.compareTo(b.orderPriority));
    _workoutWithPointsStreamController.add(WorkoutWithPointsData(
        id: workout.id,
        datetime: workout.datetime,
        duration: workout.duration,
        distance: workout.distance,
        points: points));
  }

//no plans for this atm
  Future<void> updateWorkoutData(WorkoutData workoutData) async {
    await _db.rawUpdate(
        "UPDATE $tableName SET datetime = ?, duration = ?, distance = ? WHERE id = ?",
        [
          workoutData.datetime,
          workoutData.duration,
          workoutData.distance,
          workoutData.id,
        ]);

    final workout = [..._workoutStreamController.value];
    final workoutIndex = workout.indexWhere((t) => t.id == workoutData.id);
    if (workoutIndex >= 0) {
      workout[workoutIndex] = workoutData;
    } else {
      workout.add(workoutData);
    }
    _workoutStreamController.add(workout);
  }

  Future<void> deleteWorkouts(List<WorkoutData> workouts) async {
    final workoutIds = workouts.map((workout) => workout.id).toList();
    final queryPlaceholder = List.filled(workoutIds.length, '?').join(',');
    await _db.delete(tableName,
        where: "id IN ($queryPlaceholder)", whereArgs: workoutIds);
    final newWorkouts = _workoutStreamController.value
        .where((workout) => !workoutIds.contains(workout.id))
        .toList();
    _workoutStreamController.add(newWorkouts);
  }

}

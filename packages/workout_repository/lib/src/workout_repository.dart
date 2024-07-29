import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:uuid/v4.dart';
import 'package:rxdart/subjects.dart';

class WorkoutRepository {
  static const tableName = "workouts";
  WorkoutRepository(this._db);

  final Database _db;
  late final _workoutStreamController =
      BehaviorSubject<List<WorkoutData>>.seeded(
    const [],
  );

  Stream<List<WorkoutData>> getWorkoutStream() =>
      _workoutStreamController.asBroadcastStream();

  Future<void> addWorkoutData(WorkoutData workoutData) async {
    // Update database
    final newId = const UuidV4().generate();
    await _db.rawInsert(
        "INSERT INTO $tableName(id, datetime, duration, distance) VALUES(?, ?, ?, ?)",
        [
          newId,
          workoutData.datetime,
          workoutData.duration,
          workoutData.distance,
        ]);
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

  Future<void> updateWorkoutData(WorkoutData workoutData) async {
    // Update database
    await _db.rawUpdate(
        "UPDATE $tableName SET datetime = ?, duration = ?, distance = ? WHERE id = ?",
        [
          workoutData.datetime,
          workoutData.duration,
          workoutData.distance,
          workoutData.id,
        ]);

    // Publish to stream
    final workout = [..._workoutStreamController.value];
    final workoutIndex = workout.indexWhere((t) => t.id == workoutData.id);
    if (workoutIndex >= 0) {
      workout[workoutIndex] = workoutData;
    } else {
      workout.add(workoutData);
    }
    _workoutStreamController.add(workout);
  }

  Future<void> deleteWorkoutData(WorkoutData workoutData) async {
    await _db.delete(tableName, where: "id = ?", whereArgs: [workoutData.id]);
    final workout = [..._workoutStreamController.value]
        .where((workout) => workout.id != workoutData.id)
        .toList();
    _workoutStreamController.add(workout);
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/workout_overview/entities/workout_point.dart';

part 'workout_page_event.dart';
part 'workout_page_state.dart';

class WorkoutPageBloc extends Bloc<WorkoutPageEvent, WorkoutPageState> {
  WorkoutPageBloc(
      {required this.workoutRepository,
  })
      : super(WorkoutPageState(stopwatch: Stopwatch())) {
    on<WorkoutPageDurationChanged>(_onDurationChanged);
    on<WorkoutPageStart>(_onStart);
    on<WorkoutPagePause>(_onPause);
    on<WorkoutPageResume>(_onResume);
    on<WorkoutPageStop>(_onStop);
    on<WorkoutPageSave>(_onSave);
  }

  final WorkoutRepository workoutRepository;

  Future<void> _onDurationChanged(
    WorkoutPageDurationChanged event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(duration: () => event.duration));
  }

  Future<void> _onStart(
      WorkoutPageStart event, Emitter<WorkoutPageState> emit) async {
    state.stopwatch.start();
    emit(state.copyWith(isRunning: () => true));
  }

  Future<void> _onPause(
    WorkoutPagePause event,
    Emitter<WorkoutPageState> emit,
  ) async {
    state.stopwatch.stop();
    emit(state.copyWith(isRunning: () => false));
  }

  Future<void> _onResume(
    WorkoutPageResume event,
    Emitter<WorkoutPageState> emit,
  ) async {
    state.stopwatch.start();
    emit(state.copyWith(isRunning: () => true));
  }

  Future<void> _onStop(
    WorkoutPageStop event,
    Emitter<WorkoutPageState> emit,
  ) async {
    state.stopwatch.stop();
    state.stopwatch.reset();
    emit(state.copyWith(
      isRunning: () => false,
      duration: () => Duration.zero,
      distance: () => 0.0,
    ));
  }

  Future<void> _onSave(
    WorkoutPageSave event,
    Emitter<WorkoutPageState> emit,
  ) async {
    await workoutRepository.addWorkoutData(WorkoutData.newData(
      datetime: event.datetime.toIso8601String(),
      duration: event.duration.inSeconds,
      distance: event.distance,
    ));
  }
}
